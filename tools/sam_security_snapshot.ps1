param([Parameter(Mandatory=$true)][string]$OutputPath,[switch]$VerifySignatures)
$ErrorActionPreference = 'SilentlyContinue'
$processMap = @{}
$processes = foreach ($process in Get-CimInstance Win32_Process | Select-Object -First 500) {
    $name = [string]$process.Name; $path = [string]$process.ExecutablePath
    $publisher = 'Unverified'; $signature = 'Not checked'
    if ($path -and (Test-Path -LiteralPath $path)) {
        try { $company=[Diagnostics.FileVersionInfo]::GetVersionInfo($path).CompanyName; if ($company) {$publisher=$company} } catch {}
        if ($VerifySignatures) { try { $signed=Get-AuthenticodeSignature -LiteralPath $path; $signature=[string]$signed.Status; if ($signed.Status -eq 'Valid' -and $signed.SignerCertificate.Subject) {$publisher=($signed.SignerCertificate.Subject -replace '^CN=','' -split ',')[0]} } catch {$signature='Unavailable'} }
    } elseif ([int]$process.ProcessId -le 4 -or $name -in @('Registry','Secure System','Memory Compression')) { $publisher='Microsoft Windows (protected)'; $signature='Protected system process' }
    $workingSet=0; try {$workingSet=(Get-Process -Id $process.ProcessId).WorkingSet64} catch {}
    $processMap[[int]$process.ProcessId]=@{name=$name;path=$path}
    [pscustomobject]@{name=$name;pid=[int]$process.ProcessId;memory=[long]$workingSet;path=$path;publisher=$publisher;signature=$signature}
}
$connections = foreach ($connection in Get-NetTCPConnection | Where-Object {$_.State -in @('Listen','Established','SynSent','SynReceived')} | Select-Object -First 500) {
    $pidValue=[int]$connection.OwningProcess; $owner=if($processMap.ContainsKey($pidValue)){$processMap[$pidValue]}else{@{name='unknown';path=''}}
    $remote=if($connection.State -eq 'Listen'){'Waiting for incoming traffic'}else{'{0}:{1}' -f $connection.RemoteAddress,$connection.RemotePort}
    [pscustomobject]@{name=[string]$owner.name;path=[string]$owner.path;pid=$pidValue;state=[string]$connection.State;local=('{0}:{1}' -f $connection.LocalAddress,$connection.LocalPort);remote=$remote;direction=$(if($connection.State -eq 'Listen'){'INBOUND LISTENER'}else{'ACTIVE CONNECTION'})}
}
$startup = foreach ($item in Get-CimInstance Win32_StartupCommand) {[pscustomobject]@{name=[string]$item.Name;command=[string]$item.Command;location=[string]$item.Location;user=[string]$item.User}}
$services = foreach ($service in Get-CimInstance Win32_Service | Sort-Object State,Name) {[pscustomobject]@{name=[string]$service.Name;display=[string]$service.DisplayName;state=[string]$service.State;start_mode=[string]$service.StartMode;path=[string]$service.PathName;account=[string]$service.StartName}}
$rules = foreach ($rule in Get-NetFirewallRule | Where-Object {$_.Enabled -eq 'True' -or $_.DisplayName -like 'SAM Network Guard -*'} | Select-Object -First 750) { $owned=([string]$rule.DisplayName -like 'SAM Network Guard -*'); $program=''; if($owned){$app=Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $rule | Select-Object -First 1; $program=[string]$app.Program}; [pscustomobject]@{name=[string]$rule.DisplayName;direction=[string]$rule.Direction;action=[string]$rule.Action;enabled=[string]$rule.Enabled;profile=[string]$rule.Profile;program=$program;sam_owned=$owned} }
$profiles = foreach ($profile in Get-NetFirewallProfile) {[pscustomobject]@{name=[string]$profile.Name;enabled=[bool]$profile.Enabled}}
$samRules=@($rules | Where-Object {$_.sam_owned}).Count; $lockdown=@($rules | Where-Object {$_.name -eq 'SAM Network Guard - EMERGENCY LOCKDOWN - OUT'}).Count -gt 0
$driver=Get-Service -Name 'SamNetworkGuardWfp' -ErrorAction SilentlyContinue
$payload=[ordered]@{created=(Get-Date).ToString('o');verified=[bool]$VerifySignatures;wfp_driver_installed=($null -ne $driver);wfp_driver_state=$(if($driver){[string]$driver.Status}else{'Not installed'});processes=@($processes);connections=@($connections);startup=@($startup);services=@($services);rules=@($rules);profiles=@($profiles);sam_block_rules=$samRules;lockdown=$lockdown}
$parent=Split-Path -Parent $OutputPath; New-Item -ItemType Directory -Path $parent -Force | Out-Null
$payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
