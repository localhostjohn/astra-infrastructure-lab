#Requires -Version 5.1
Set-StrictMode -Version Latest

function New-AstraCheck {
    param([string]$Name, [string]$Status, $Data, [string]$NextStep, [string]$Detail)
    [pscustomobject]@{ Name=$Name; Status=$Status; Data=$Data; Detail=$Detail; NextStep=$NextStep }
}

function Get-AstraLocalNetwork {
    # Preserve interface indices so VPN and multi-adapter evidence is interpretable.
    $configs = @(Get-NetIPConfiguration -ErrorAction Stop | ForEach-Object {
        [pscustomobject]@{
            InterfaceIndex=$_.InterfaceIndex
            InterfaceAlias=$_.InterfaceAlias
            IPv4=@($_.IPv4Address | ForEach-Object { $_.IPAddress })
            IPv6=@($_.IPv6Address | ForEach-Object { $_.IPAddress })
            IPv4Gateway=@($_.IPv4DefaultGateway | ForEach-Object { $_.NextHop })
            IPv6Gateway=@($_.IPv6DefaultGateway | ForEach-Object { $_.NextHop })
            DnsServers=@($_.DNSServer | ForEach-Object { $_.ServerAddresses })
        }
    })
    $routes = @(Get-NetRoute -ErrorAction Stop | Where-Object {
        $_.DestinationPrefix -in @('0.0.0.0/0','::/0')
    } | Select-Object InterfaceIndex,DestinationPrefix,NextHop,RouteMetric)
    [pscustomobject]@{ Interfaces=$configs; DefaultRoutes=$routes }
}

function Resolve-AstraAddress {
    param([string]$Target, [int]$TimeoutSeconds)
    $literal = $null
    if ([System.Net.IPAddress]::TryParse($Target, [ref]$literal)) { return $literal }
    # OS resolver includes hosts-file and DNS policy behaviour. This is not a
    # direct query to each configured DNS server. Wait bounds the caller.
    $task = [System.Net.Dns]::GetHostAddressesAsync($Target)
    if (-not $task.Wait($TimeoutSeconds * 1000)) { throw 'Name resolution timed out.' }
    $addresses = @($task.GetAwaiter().GetResult())
    if ($addresses.Count -eq 0) { throw 'Name resolution returned no addresses.' }
    $addresses
}

function Test-AstraPing {
    param([System.Net.IPAddress]$Address, [int]$TimeoutSeconds)
    $ping = New-Object System.Net.NetworkInformation.Ping
    try {
        $reply = $ping.Send($Address, $TimeoutSeconds * 1000)
        [pscustomobject]@{ Address=$Address.ToString(); Status=$reply.Status.ToString(); RoundtripMs=$reply.RoundtripTime }
    } finally { $ping.Dispose() }
}

function Test-AstraTcp {
    param([System.Net.IPAddress]$Address, [int]$Port, [int]$TimeoutSeconds)
    $client = New-Object System.Net.Sockets.TcpClient($Address.AddressFamily)
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $task = $client.ConnectAsync($Address, $Port)
        if (-not $task.Wait($TimeoutSeconds * 1000)) { throw 'TCP connection timed out.' }
        $task.GetAwaiter().GetResult()
        [pscustomobject]@{ Address=$Address.ToString(); Port=$Port; Connected=$true; DurationMs=$watch.ElapsedMilliseconds; Error=$null }
    } catch {
        [pscustomobject]@{ Address=$Address.ToString(); Port=$Port; Connected=$false; DurationMs=$watch.ElapsedMilliseconds; Error=$_.Exception.GetBaseException().Message }
    } finally { $client.Dispose(); $watch.Stop() }
}

function Test-AstraHttp {
    param([string]$Target, [int]$Port, [string]$Scheme, [int]$TimeoutSeconds)
    Add-Type -AssemblyName System.Net.Http
    $builder = New-Object System.UriBuilder($Scheme, $Target, $Port, '/')
    $handler = New-Object System.Net.Http.HttpClientHandler
    $handler.AllowAutoRedirect = $false
    # Direct test: do not use a system proxy, send credentials or bypass TLS.
    $handler.UseProxy = $false
    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromSeconds($TimeoutSeconds)
    $response = $null
    try {
        $task = $client.GetAsync($builder.Uri, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead)
        $response = $task.GetAwaiter().GetResult()
        [pscustomobject]@{ Uri=$builder.Uri.AbsoluteUri; StatusCode=[int]$response.StatusCode; Reason=$response.ReasonPhrase }
    } finally {
        if ($null -ne $response) { $response.Dispose() }
        $client.Dispose()
        $handler.Dispose()
    }
}

function Invoke-AstraTriage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Target,
        [ValidateRange(1,65535)][int]$Port=443,
        [ValidateSet('','http','https')][string]$HttpScheme='',
        [ValidateRange(1,30)][int]$TimeoutSeconds=5
    )
    if ($env:OS -ne 'Windows_NT') { throw 'Astra Network Triage requires Windows.' }
    $literal = $null
    if (-not [System.Net.IPAddress]::TryParse($Target,[ref]$literal) -and
        [System.Uri]::CheckHostName($Target) -ne [System.UriHostNameType]::Dns) {
        throw 'Target must be a hostname or IP address, without a URL, path or port.'
    }
    $checks = New-Object 'System.Collections.Generic.List[object]'
    try {
        $local = Get-AstraLocalNetwork
        $status = if (@($local.Interfaces).Count -gt 0) { 'Observed' } else { 'Attention' }
        $checks.Add((New-AstraCheck 'LocalNetwork' $status $local 'Inspect the relevant interface address, DNS settings and routes; a default route is not required for every local target.' 'Configuration inventory does not prove the selected route or connectivity.'))
    } catch {
        $checks.Add((New-AstraCheck 'LocalNetwork' 'Error' $null 'Check availability and permissions for the Windows NetTCPIP module.' $_.Exception.GetBaseException().Message))
    }
    $addresses = @()
    try {
        $addresses = @(Resolve-AstraAddress -Target $Target -TimeoutSeconds $TimeoutSeconds)
        $checks.Add((New-AstraCheck 'Resolution' 'Pass' @($addresses | ForEach-Object { $_.ToString() }) '' 'Addresses obtained via the OS resolver; an IP literal bypasses DNS.'))
    } catch {
        $checks.Add((New-AstraCheck 'Resolution' 'Attention' $null 'Check spelling, hosts-file entries, configured DNS, VPN/split DNS and resolver reachability.' $_.Exception.GetBaseException().Message))
    }
    if ($addresses.Count -eq 0) {
        $checks.Add((New-AstraCheck 'ICMP' 'Skipped' $null 'Resolve the target first.' 'No resolved address.'))
        $checks.Add((New-AstraCheck 'TCP' 'Skipped' $null 'Resolve the target first.' 'No resolved address.'))
    } else {
        # Limit multi-address targets to avoid unexpectedly long diagnostic runs.
        foreach ($address in ($addresses | Select-Object -First 8)) {
            try {
                $reply = Test-AstraPing -Address $address -TimeoutSeconds $TimeoutSeconds
                $status = if ($reply.Status -eq 'Success') { 'Pass' } else { 'Inconclusive' }
                $checks.Add((New-AstraCheck 'ICMP' $status $reply 'Compare the TCP result; ICMP may be filtered even when a service is reachable.' 'Ping is supporting evidence, not a service health test.'))
            } catch {
                $checks.Add((New-AstraCheck 'ICMP' 'Inconclusive' $address.ToString() 'Compare the TCP result; ICMP may be blocked or unavailable.' $_.Exception.GetBaseException().Message))
            }
            $tcp = Test-AstraTcp -Address $address -Port $Port -TimeoutSeconds $TimeoutSeconds
            $status = if ($tcp.Connected) { 'Pass' } else { 'Attention' }
            $checks.Add((New-AstraCheck 'TCP' $status $tcp 'If unsuccessful, check the listener, host/network firewall, VPN routes and destination. A connection alone does not prove application health.' 'Connection tested to this specific resolved address.'))
        }
    }
    if (-not $HttpScheme) {
        $checks.Add((New-AstraCheck 'HTTP' 'Skipped' $null 'Use -HttpScheme http or https for a web endpoint.' 'Optional check not requested.'))
    } elseif ($addresses.Count -eq 0) {
        $checks.Add((New-AstraCheck 'HTTP' 'Skipped' $null 'Resolve the target first.' 'No resolved address.'))
    } else {
        try {
            $http = Test-AstraHttp -Target $Target -Port $Port -Scheme $HttpScheme -TimeoutSeconds $TimeoutSeconds
            $status = if ($http.StatusCode -ge 200 -and $http.StatusCode -lt 300) { 'Pass' } else { 'Attention' }
            $checks.Add((New-AstraCheck 'HTTP' $status $http 'For redirects inspect the intended destination; for 401/403 check access requirements; for 4xx/5xx inspect the application and proxy.' 'Direct unauthenticated GET /; redirects are not followed. A non-2xx response still proves an HTTP response was received.'))
        } catch {
            $checks.Add((New-AstraCheck 'HTTP' 'Attention' $null 'Check certificate trust/name/expiry, TLS compatibility and application/proxy logs. HTTPS errors can occur even when TCP passes.' $_.Exception.GetBaseException().Message))
        }
    }
    $overall = if (@($checks | Where-Object { $_.Status -in @('Attention','Error') }).Count -gt 0) { 'Attention' } else { 'Completed' }
    [pscustomobject]@{
        SchemaVersion='1.0'; ToolVersion='0.1.0'; GeneratedAtUtc=[DateTime]::UtcNow.ToString('o')
        Target=$Target; Port=$Port; HttpScheme=$HttpScheme; OverallStatus=$overall
        Limits='Up to 8 resolved addresses; timeout per operation, not the whole run. HTTP resolves the hostname independently. No root-cause certainty or overall network-health guarantee.'
        Checks=@($checks.ToArray())
    }
}

function Export-AstraTriageReport {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Report, [Parameter(Mandatory)][string]$OutputDirectory)
    $directory = [System.IO.Path]::GetFullPath($OutputDirectory)
    $null = [System.IO.Directory]::CreateDirectory($directory)
    $stem = 'astra-triage-' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '-' + [Guid]::NewGuid().ToString('N')
    $jsonPath = Join-Path $directory ($stem + '.json')
    $textPath = Join-Path $directory ($stem + '.txt')
    $lines = @(('Astra Network Triage ' + $Report.ToolVersion),
        ('UTC: ' + $Report.GeneratedAtUtc),
        ('Target: ' + $Report.Target + ':' + $Report.Port),
        ('Status: ' + $Report.OverallStatus), '', $Report.Limits, '')
    foreach ($check in $Report.Checks) {
        $lines += "[$($check.Status)] $($check.Name)"
        $lines += $check.Detail
        $lines += ($check.Data | ConvertTo-Json -Depth 10 -Compress)
        if ($check.NextStep) { $lines += 'Next: ' + $check.NextStep }
        $lines += ''
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    foreach ($entry in @(
        @{Path=$jsonPath; Content=($Report | ConvertTo-Json -Depth 12)},
        @{Path=$textPath; Content=($lines -join [Environment]::NewLine)}
    )) {
        $stream = [System.IO.File]::Open($entry.Path, [System.IO.FileMode]::CreateNew)
        try {
            $bytes = $encoding.GetBytes($entry.Content)
            $stream.Write($bytes,0,$bytes.Length)
        } finally { $stream.Dispose() }
    }
    $jsonPath; $textPath
}

Export-ModuleMember -Function Invoke-AstraTriage,Export-AstraTriageReport
