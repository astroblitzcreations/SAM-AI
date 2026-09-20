param([Parameter(Mandatory=$true)][string]$OutputPath)
$ErrorActionPreference = 'Continue'
$lines = [System.Collections.Generic.List[string]]::new()
function Add-Section([string]$Title) { $lines.Add(''); $lines.Add(('=' * 72)); $lines.Add($Title); $lines.Add(('=' * 72)) }
function Add-Data($Value) {
    if ($null -eq $Value) { $lines.Add('Unavailable or no results.'); return }
    $text = ($Value | Out-String -Width 220).TrimEnd()
    if ([string]::IsNullOrWhiteSpace($text)) { $lines.Add('Unavailable or no results.') } else { $lines.Add($text) }
}
$lines.Add('SAM-AI READ-ONLY WINDOWS SECURITY AUDIT')
$lines.Add(('Created: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$lines.Add(('Computer: {0}  User: {1}' -f $env:COMPUTERNAME, $env:USERNAME))
$lines.Add('This report is observational. An unfamiliar item is not automatically malicious.')

Add-Section 'MICROSOFT DEFENDER'
try { Add-Data (Get-MpComputerStatus | Select-Object AntivirusEnabled,AntispywareEnabled,RealTimeProtectionEnabled,BehaviorMonitorEnabled,IoavProtectionEnabled,NISEnabled,AntivirusSignatureLastUpdated,QuickScanAge,FullScanAge) } catch { $lines.Add(('Defender status unavailable: {0}' -f $_.Exception.Message)) }

Add-Section 'WINDOWS FIREWALL PROFILES'
try { Add-Data (Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction,NotifyOnListen) } catch { $lines.Add(('Firewall status unavailable: {0}' -f $_.Exception.Message)) }

Add-Section 'LISTENING TCP PORTS AND OWNER PROCESSES'
try {
    $listeners = Get-NetTCPConnection -State Listen | Sort-Object LocalPort | Select-Object -First 150
    $rows = foreach ($item in $listeners) {
        $processName = try { (Get-Process -Id $item.OwningProcess -ErrorAction Stop).ProcessName } catch { 'unknown' }
        [pscustomobject]@{Address=$item.LocalAddress;Port=$item.LocalPort;PID=$item.OwningProcess;Process=$processName}
    }
    Add-Data $rows
} catch { $lines.Add(('Listening-port inventory unavailable: {0}' -f $_.Exception.Message)) }

Add-Section 'ESTABLISHED TCP CONNECTIONS'
try {
    $connections = Get-NetTCPConnection -State Established | Sort-Object OwningProcess,RemoteAddress | Select-Object -First 200
    $rows = foreach ($item in $connections) {
        $processName = try { (Get-Process -Id $item.OwningProcess -ErrorAction Stop).ProcessName } catch { 'unknown' }
        [pscustomobject]@{Local=('{0}:{1}' -f $item.LocalAddress,$item.LocalPort);Remote=('{0}:{1}' -f $item.RemoteAddress,$item.RemotePort);PID=$item.OwningProcess;Process=$processName}
    }
    Add-Data $rows
} catch { $lines.Add(('Connection inventory unavailable: {0}' -f $_.Exception.Message)) }

Add-Section 'STARTUP PROGRAMS'
try { Add-Data (Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location,User) } catch { $lines.Add(('Startup inventory unavailable: {0}' -f $_.Exception.Message)) }

Add-Section 'NON-MICROSOFT SCHEDULED TASKS (ENABLED OR RUNNING)'
try { Add-Data (Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '\Microsoft\*' -and $_.State -ne 'Disabled' } | Select-Object -First 150 TaskName,TaskPath,State,Author) } catch { $lines.Add(('Scheduled-task inventory unavailable: {0}' -f $_.Exception.Message)) }

Add-Section 'RECENT FAILED WINDOWS SIGN-INS (EVENT 4625, LAST 7 DAYS)'
try { Add-Data (Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625;StartTime=(Get-Date).AddDays(-7)} -MaxEvents 40 -ErrorAction Stop | Select-Object TimeCreated,Id,ProviderName,Message) } catch { $lines.Add('Security events require administrator/event-log permission or no matching events were available.') }

Add-Section 'RECENT INSTALLED WINDOWS HOTFIXES'
try { Add-Data (Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 20 HotFixID,Description,InstalledOn,InstalledBy) } catch { $lines.Add(('Hotfix inventory unavailable: {0}' -f $_.Exception.Message)) }

Add-Section 'INTERPRETATION SAFETY'
$lines.Add('Do not block, disable, quarantine, or delete an item solely because it appears here.')
$lines.Add('Verify process file location, digital signature, publisher, expected software, and repeated behavior first.')
$lines.Add('Use Microsoft Defender and Windows Security for malware scanning and remediation.')
$parent = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Path $parent -Force | Out-Null
$lines | Set-Content -LiteralPath $OutputPath -Encoding UTF8
