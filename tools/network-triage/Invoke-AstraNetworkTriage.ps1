#Requires -Version 5.1
<#
.SYNOPSIS
Collects read-only network evidence for one explicitly selected service.
.EXAMPLE
.\Invoke-AstraNetworkTriage.ps1 -Target portal.example.test -Port 443 -HttpScheme https
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Target,
    [ValidateRange(1,65535)][int]$Port = 443,
    [ValidateSet('http','https')][string]$HttpScheme,
    [ValidateRange(1,30)][int]$TimeoutSeconds = 5,
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AstraNetworkTriage.psm1') -Force
$report = Invoke-AstraTriage -Target $Target -Port $Port -HttpScheme $HttpScheme -TimeoutSeconds $TimeoutSeconds
if ($OutputDirectory) {
    $paths = Export-AstraTriageReport -Report $report -OutputDirectory $OutputDirectory
    Write-Verbose "Reports saved: $($paths -join ', ')"
}
$report
