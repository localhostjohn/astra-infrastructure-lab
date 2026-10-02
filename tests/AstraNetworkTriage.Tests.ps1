Import-Module (Join-Path $PSScriptRoot '../tools/network-triage/AstraNetworkTriage.psm1') -Force

InModuleScope AstraNetworkTriage {
    Describe 'Service triage interpretation' {
        BeforeEach {
            Mock Get-AstraLocalNetwork { [pscustomobject]@{ Interfaces=@(@{IPv4='192.0.2.10'}); DefaultRoutes=@() } }
            Mock Resolve-AstraAddress { [System.Net.IPAddress]::Parse('192.0.2.20') }
            Mock Test-AstraPing { [pscustomobject]@{Address='192.0.2.20'; Status='TimedOut'; RoundtripMs=0} }
            Mock Test-AstraTcp { [pscustomobject]@{Address='192.0.2.20'; Port=443; Connected=$true; Error=$null} }
            Mock Test-AstraHttp { [pscustomobject]@{Uri='https://portal.example.test/'; StatusCode=200; Reason='OK'} }
        }
        It 'does not declare a reachable service down because ICMP is filtered' {
            $r = Invoke-AstraTriage -Target portal.example.test -HttpScheme https
            $r.OverallStatus | Should -Be Completed
            ($r.Checks | Where-Object Name -eq ICMP).Status | Should -Be Inconclusive
            ($r.Checks | Where-Object Name -eq TCP).Status | Should -Be Pass
        }
        It 'skips dependent probes when resolution fails' {
            Mock Resolve-AstraAddress { throw 'Resolver unavailable' }
            $r = Invoke-AstraTriage -Target portal.example.test -HttpScheme https
            $r.OverallStatus | Should -Be Attention
            ($r.Checks | Where-Object Name -eq TCP).Status | Should -Be Skipped
            Should -Invoke Test-AstraTcp -Times 0 -Exactly
            Should -Invoke Test-AstraHttp -Times 0 -Exactly
        }
        It 'records a TCP failure without claiming a firewall is the cause' {
            Mock Test-AstraTcp { [pscustomobject]@{Connected=$false; Error='Connection refused'} }
            $r = Invoke-AstraTriage -Target portal.example.test
            ($r.Checks | Where-Object Name -eq TCP).Status | Should -Be Attention
            $r.OverallStatus | Should -Be Attention
        }
        It 'distinguishes HTTP access failure from successful TCP' {
            Mock Test-AstraHttp { [pscustomobject]@{StatusCode=403; Reason='Forbidden'} }
            $r = Invoke-AstraTriage -Target portal.example.test -HttpScheme https
            ($r.Checks | Where-Object Name -eq TCP).Status | Should -Be Pass
            ($r.Checks | Where-Object Name -eq HTTP).Status | Should -Be Attention
        }
        It 'preserves certificate errors as HTTP attention' {
            Mock Test-AstraHttp { throw 'Certificate name mismatch' }
            $r = Invoke-AstraTriage -Target portal.example.test -HttpScheme https
            ($r.Checks | Where-Object Name -eq HTTP).Detail | Should -Match 'Certificate name mismatch'
        }
        It 'continues remote checks when local inventory is unavailable' {
            Mock Get-AstraLocalNetwork { throw 'Module unavailable' }
            $r = Invoke-AstraTriage -Target portal.example.test
            ($r.Checks | Where-Object Name -eq LocalNetwork).Status | Should -Be Error
            ($r.Checks | Where-Object Name -eq TCP).Status | Should -Be Pass
        }
        It 'caps probes for multi-address targets' {
            Mock Resolve-AstraAddress { 1..12 | ForEach-Object { [System.Net.IPAddress]::Parse("192.0.2.$_") } }
            $r = Invoke-AstraTriage -Target portal.example.test
            @($r.Checks | Where-Object Name -eq TCP).Count | Should -Be 8
            Should -Invoke Test-AstraTcp -Times 8 -Exactly
        }
        It 'rejects URLs before probing' {
            { Invoke-AstraTriage -Target 'https://portal.example.test/path' } | Should -Throw '*hostname or IP*'
            Should -Invoke Resolve-AstraAddress -Times 0 -Exactly
        }
        It 'exports parseable JSON and readable text without overwriting reports' {
            $r = Invoke-AstraTriage -Target portal.example.test
            $first = @(Export-AstraTriageReport -Report $r -OutputDirectory $TestDrive)
            $second = @(Export-AstraTriageReport -Report $r -OutputDirectory $TestDrive)
            $first.Count | Should -Be 2
            $first[0] | Should -Not -Be $second[0]
            (Get-Content $first[0] -Raw | ConvertFrom-Json).Target | Should -Be portal.example.test
            Get-Content $first[1] -Raw | Should -Match '\[Inconclusive\] ICMP'
        }
    }
    Describe 'Actual bounded loopback probes' {
        It 'collects Windows configuration without assuming IPv6 gateways exist' {
            $local = Get-AstraLocalNetwork
            @($local.Interfaces).Count | Should -BeGreaterThan 0
        }
        It 'connects to an open TCP listener and detects a closed port' {
            $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback,0)
            try {
                $listener.Start()
                $port = $listener.LocalEndpoint.Port
                (Test-AstraTcp -Address ([System.Net.IPAddress]::Loopback) -Port $port -TimeoutSeconds 1).Connected | Should -BeTrue
            } finally { $listener.Stop() }
            (Test-AstraTcp -Address ([System.Net.IPAddress]::Loopback) -Port $port -TimeoutSeconds 1).Connected | Should -BeFalse
        }
        It 'accepts an IPv6 literal without performing DNS resolution' {
            @(Resolve-AstraAddress -Target '::1' -TimeoutSeconds 1)[0].ToString() | Should -Be '::1'
        }
    }
}
