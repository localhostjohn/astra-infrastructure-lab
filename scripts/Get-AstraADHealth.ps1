#Requires -Version 5.1
<#
.SYNOPSIS
    Collects a read-only Active Directory lab inventory.
.DESCRIPTION
    Queries domain, forest and domain-controller information using the
    ActiveDirectory module. Optional replication checks report currently
    recorded failures; they are not a complete replication health assessment.
    No directory objects, permissions, policies or services are modified.
.PARAMETER Server
    Optional domain controller or domain DNS name used for directory queries.
.PARAMETER IncludeReplication
    Query current replication failures for the discovered domain.
.PARAMETER OutputPath
    Optional local JSON destination. The parent directory must exist and the
    destination must not already exist. No file is written by default.
.EXAMPLE
    .\Get-AstraADHealth.ps1 -Server dc01.lab.example.test -IncludeReplication
.NOTES
    Lab learning tool. Review output before sharing; it may contain private
    hostnames, sites, domain names and other environment metadata.
#>
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()][string]$Server,
    [switch]$IncludeReplication,
    [ValidateNotNullOrEmpty()][string]$OutputPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$resolvedOutputPath = $null
if ($PSBoundParameters.ContainsKey('OutputPath')) {
    $resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
    $parentPath = Split-Path -Path $resolvedOutputPath -Parent
    if (-not (Test-Path -LiteralPath $parentPath -PathType Container)) {
        throw 'The output directory does not exist. Create a private directory first.'
    }
    if (Test-Path -LiteralPath $resolvedOutputPath) {
        throw 'The output file already exists. Choose a new filename to preserve previous evidence.'
    }
}
Import-Module ActiveDirectory -ErrorAction Stop
$commonParameters = @{ ErrorAction = 'Stop' }
if ($PSBoundParameters.ContainsKey('Server')) { $commonParameters.Server = $Server }
$checks = [System.Collections.Generic.List[object]]::new()
function Invoke-ReadOnlyCheck {
    param([Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][scriptblock]$Action)
    try {
        $data = & $Action
        $item = [pscustomobject]@{ Name = $Name; Status = 'Completed'; Data = $data; Error = $null }
    }
    catch {
        $item = [pscustomobject]@{ Name = $Name; Status = 'Failed'; Data = $null; Error = $_.Exception.Message }
    }
    [void]$checks.Add($item)
    return $item
}
$domainCheck = Invoke-ReadOnlyCheck -Name 'Domain' -Action {
    $domain = Get-ADDomain @commonParameters
    [pscustomobject]@{
        DNSRoot = $domain.DNSRoot
        Forest = $domain.Forest
        DomainMode = [string]$domain.DomainMode
        PDCEmulator = $domain.PDCEmulator
        RIDMaster = $domain.RIDMaster
        InfrastructureMaster = $domain.InfrastructureMaster
    }
}
[void](Invoke-ReadOnlyCheck -Name 'Forest' -Action {
    $forest = Get-ADForest @commonParameters
    [pscustomobject]@{
        Name = $forest.Name
        ForestMode = [string]$forest.ForestMode
        Domains = @($forest.Domains)
        Sites = @($forest.Sites)
        SchemaMaster = $forest.SchemaMaster
        DomainNamingMaster = $forest.DomainNamingMaster
    }
})
[void](Invoke-ReadOnlyCheck -Name 'DomainControllers' -Action {
    $controllers = @(Get-ADDomainController -Filter * @commonParameters |
        Select-Object HostName, Site, OperatingSystem, IsGlobalCatalog, IsReadOnly)
    [pscustomobject]@{ Count = $controllers.Count; Controllers = $controllers }
})
if ($IncludeReplication) {
    if ($domainCheck.Status -eq 'Completed') {
        $replicationCheck = Invoke-ReadOnlyCheck -Name 'ReplicationFailures' -Action {
            $failures = @(Get-ADReplicationFailure -Target $domainCheck.Data.DNSRoot -Scope Domain -ErrorAction Stop |
                Select-Object Server, Partner, FirstFailureTime, FailureCount, LastError)
            [pscustomobject]@{ FailureCount = $failures.Count; Failures = $failures }
        }
        if ($replicationCheck.Status -eq 'Completed' -and $replicationCheck.Data.FailureCount -gt 0) {
            $replicationCheck.Status = 'Attention'
        }
    }
    else {
        [void]$checks.Add([pscustomobject]@{
            Name = 'ReplicationFailures'; Status = 'Skipped'; Data = $null
            Error = 'The domain query did not complete.'
        })
    }
}
$items = @($checks.ToArray())
$attentionCount = @($items | Where-Object { $_.Status -in @('Failed', 'Attention') }).Count
$report = [pscustomobject]@{
    SchemaVersion = '1.0'
    GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    OverallStatus = if ($attentionCount -gt 0) { 'Attention' } else { 'Completed' }
    Disclaimer = 'Read-only inventory; not a complete AD health or security assessment.'
    Checks = $items
}
if ($null -ne $resolvedOutputPath) {
    $json = $report | ConvertTo-Json -Depth 8
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $bytes = $encoding.GetBytes($json)
    $stream = [System.IO.File]::Open(
        $resolvedOutputPath, [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write, [System.IO.FileShare]::None
    )
    try { $stream.Write($bytes, 0, $bytes.Length) }
    finally { $stream.Dispose() }
}
Write-Output $report
