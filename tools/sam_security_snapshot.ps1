param([Parameter(Mandatory=$true)][string]$OutputPath)
$ErrorActionPreference = 'SilentlyContinue'
$processMap = @{}
$processes = foreach ($process in Get-CimInstance Win32_Process | Select-Object -First 400) {
    $name = [string]$process.Name
    $path = [string]$process.ExecutablePath
    $publisher = 'Unverified'
    if ($path -and (Test-Path -LiteralPath $path)) {
        try {
            $company = [Diagnostics.FileVersionInfo]::GetVersionInfo($path).CompanyName
            if (-not [string]::IsNullOrWhiteSpace($company)) { $publisher = $company }
        } catch {}
    }
    $workingSet = 0
    try { $workingSet = (Get-Process -Id $process.ProcessId).WorkingSet64 } catch {}
    $processMap[[int]$process.ProcessId] = $name
    [pscustomobject]@{name=$name;pid=[int]$process.ProcessId;memory=[long]$workingSet;path=$path;publisher=$publisher}
}
$connections = foreach ($connection in Get-NetTCPConnection | Where-Object { $_.State -in @('Listen','Established','SynSent','SynReceived') } | Select-Object -First 350) {
    $pidValue = [int]$connection.OwningProcess
    $processName = if ($processMap.ContainsKey($pidValue)) { $processMap[$pidValue] } else { 'unknown' }
    $remote = if ($connection.State -eq 'Listen') { 'Waiting for incoming traffic' } else { '{0}:{1}' -f $connection.RemoteAddress,$connection.RemotePort }
    [pscustomobject]@{
        name=$processName;pid=$pidValue;state=[string]$connection.State
        local=('{0}:{1}' -f $connection.LocalAddress,$connection.LocalPort)
        remote=$remote;direction=$(if ($connection.State -eq 'Listen') {'INBOUND LISTENER'} else {'ACTIVE CONNECTION'})
    }
}
$profiles = foreach ($profile in Get-NetFirewallProfile) { [pscustomobject]@{name=[string]$profile.Name;enabled=[bool]$profile.Enabled} }
$samRules = @(Get-NetFirewallRule -DisplayName 'SAM Network Guard -*' -ErrorAction SilentlyContinue).Count
$payload = [ordered]@{created=(Get-Date).ToString('o');processes=@($processes);connections=@($connections);profiles=@($profiles);sam_block_rules=$samRules}
$parent = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Path $parent -Force | Out-Null
$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
