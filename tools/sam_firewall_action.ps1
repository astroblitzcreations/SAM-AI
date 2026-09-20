param(
    [Parameter(Mandatory=$true)][ValidateSet('block','unblock')][string]$Action,
    [Parameter(Mandatory=$true)][string]$AppName,
    [Parameter(Mandatory=$true)][string]$AppPath
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $AppPath -PathType Leaf)) { throw 'The selected executable no longer exists.' }
$safeName = ($AppName -replace '[^a-zA-Z0-9._ -]','').Trim()
if ([string]::IsNullOrWhiteSpace($safeName)) { $safeName = [IO.Path]::GetFileName($AppPath) }
$inName = "SAM Network Guard - $safeName - IN"
$outName = "SAM Network Guard - $safeName - OUT"
Get-NetFirewallRule -DisplayName $inName,$outName -ErrorAction SilentlyContinue | Remove-NetFirewallRule
if ($Action -eq 'block') {
    New-NetFirewallRule -DisplayName $inName -Direction Inbound -Action Block -Program $AppPath -Profile Any -Enabled True | Out-Null
    New-NetFirewallRule -DisplayName $outName -Direction Outbound -Action Block -Program $AppPath -Profile Any -Enabled True | Out-Null
}
