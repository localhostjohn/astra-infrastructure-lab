#Requires -Version 5.1
# Pester 5 tests. These tests use mock directory responses, not a live AD.
BeforeAll {
    $scriptPath = Join-Path $PSScriptRoot '..\scripts\Get-AstraADHealth.ps1'
    function Get-ADDomain { param($Server) throw 'Not mocked' }
    function Get-ADForest { param($Server) throw 'Not mocked' }
    function Get-ADDomainController { param($Filter, $Server) throw 'Not mocked' }
    function Get-ADReplicationFailure { param($Target, $Scope) throw 'Not mocked' }
}

Describe 'Get-AstraADHealth' {
    BeforeEach {
        Mock Import-Module {}
        Mock Get-ADDomain {
            [pscustomobject]@{
                DNSRoot = 'lab.example.test'; Forest = 'lab.example.test'
                DomainMode = 'Windows2016Domain'; PDCEmulator = 'dc01.lab.example.test'
                RIDMaster = 'dc01.lab.example.test'; InfrastructureMaster = 'dc01.lab.example.test'
            }
        }
        Mock Get-ADForest {
            [pscustomobject]@{
                Name = 'lab.example.test'; ForestMode = 'Windows2016Forest'
                Domains = @('lab.example.test'); Sites = @('Lab-Site')
                SchemaMaster = 'dc01.lab.example.test'; DomainNamingMaster = 'dc01.lab.example.test'
            }
        }
        Mock Get-ADDomainController {
            [pscustomobject]@{
                HostName = 'dc01.lab.example.test'; Site = 'Lab-Site'
                OperatingSystem = 'Windows Server (test fixture)'
                IsGlobalCatalog = $true; IsReadOnly = $false
            }
        }
        Mock Get-ADReplicationFailure { @() }
    }
    It 'returns the expected read-only inventory sections' {
        $report = & $scriptPath
        $report.OverallStatus | Should -Be 'Completed'
        @($report.Checks).Count | Should -Be 3
        $report.Checks[0].Data.DNSRoot | Should -Be 'lab.example.test'
        $report.Checks[2].Data.Count | Should -Be 1
        Should -Invoke Get-ADReplicationFailure -Exactly -Times 0
    }
    It 'uses the supplied server for directory queries' {
        $null = & $scriptPath -Server 'dc01.lab.example.test'
        Should -Invoke Get-ADDomain -Exactly -Times 1 -ParameterFilter { $Server -eq 'dc01.lab.example.test' }
        Should -Invoke Get-ADForest -Exactly -Times 1 -ParameterFilter { $Server -eq 'dc01.lab.example.test' }
        Should -Invoke Get-ADDomainController -Exactly -Times 1 -ParameterFilter { $Server -eq 'dc01.lab.example.test' }
    }
    It 'reports replication failures as attention rather than declaring health' {
        Mock Get-ADReplicationFailure {
            [pscustomobject]@{
                Server = 'dc01.lab.example.test'; Partner = 'dc02.lab.example.test'
                FirstFailureTime = [datetime]'2026-01-01'; FailureCount = 2; LastError = 1722
            }
        }
        $report = & $scriptPath -IncludeReplication
        $report.OverallStatus | Should -Be 'Attention'
        $report.Checks[-1].Data.FailureCount | Should -Be 1
        Should -Invoke Get-ADReplicationFailure -Exactly -Times 1
    }
    It 'records an individual query error and continues other checks' {
        Mock Get-ADForest { throw 'Simulated discovery failure' }
        $report = & $scriptPath
        $report.OverallStatus | Should -Be 'Attention'
        $report.Checks[1].Status | Should -Be 'Failed'
        $report.Checks[2].Status | Should -Be 'Completed'
    }
    It 'writes JSON only when a new destination is requested' {
        $path = Join-Path $TestDrive 'ad-health.json'
        $null = & $scriptPath -OutputPath $path
        Test-Path -LiteralPath $path | Should -BeTrue
        { & $scriptPath -OutputPath $path } | Should -Throw
        $saved = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        $saved.SchemaVersion | Should -Be '1.0'
    }
    It 'contains no directory mutation or arbitrary-command execution calls' {
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$errors)
        @($errors).Count | Should -Be 0
        $commands = @($ast.FindAll({ param($node)
            $node -is [System.Management.Automation.Language.CommandAst]
        }, $true) | ForEach-Object { $_.GetCommandName() })
        @($commands | Where-Object {
            $_ -match '^(Set|New|Remove|Add|Clear|Enable|Disable|Move|Rename|Reset|Unlock)-AD' -or
            $_ -in @('Invoke-Expression', 'Start-Process', 'Invoke-Command')
        }).Count | Should -Be 0
    }
}
