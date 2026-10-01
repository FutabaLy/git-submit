param([string]$DataDir)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'package-common.ps1')
$whaleRoot = Get-WhaleFullPath (Join-Path $PSScriptRoot '..')
if (!$DataDir) {
    $whaleCodex = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
    $DataDir = if ($env:WHALE_HOME) { $env:WHALE_HOME } else { Join-Path $whaleCodex 'whale-widget' }
}
$DataDir = Get-WhaleFullPath $DataDir
Assert-WhalePlainPath $DataDir
$whaleElectron = Join-Path $DataDir 'desktop-runtime\node_modules\electron\dist\electron.exe'
if (!(Test-Path -LiteralPath $whaleElectron)) { throw 'Install desktop runtime first.' }
if (Get-ScheduledTask -TaskName 'Codex API Balance Whale' -ErrorAction SilentlyContinue) { throw 'Disable the existing scheduled follow task before choosing Startup folder mode.' }
$whaleScript = Join-Path $whaleRoot 'desktop\supervisor.ps1'
$whaleLink = Join-Path (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup') 'Codex API Balance Whale.lnk'
$whaleShell = New-Object -ComObject WScript.Shell
if (Test-Path -LiteralPath $whaleLink) {
    $whaleOld = $whaleShell.CreateShortcut($whaleLink)
    if (!$whaleOld.Arguments.Contains($whaleScript) -or !$whaleOld.Arguments.Contains($DataDir)) { throw 'The Startup shortcut belongs to another installation.' }
}
$whaleLauncher = & (Join-Path $PSScriptRoot 'build-launcher.ps1') -DataDir $DataDir
$whaleArgs = '--script "' + $whaleScript + '" --data "' + $DataDir + '"'
@{ enabled=$true; pluginRoot=$whaleRoot; electronPath=$whaleElectron; powerShellPath=(Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'); launcherPath=$whaleLauncher; taskName='Codex API Balance Whale'; mode='follow-codex'; revision='follow-v3'; launchMode='startup-folder' } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $DataDir 'follow-config.json') -Encoding UTF8
$whaleShortcut = $whaleShell.CreateShortcut($whaleLink)
$whaleShortcut.TargetPath = $whaleLauncher
$whaleShortcut.Arguments = $whaleArgs
$whaleShortcut.WorkingDirectory = $DataDir
$whaleShortcut.Description = 'Codex API Balance Whale'
New-Item -ItemType Directory -Path (Split-Path -Parent $whaleLink) -Force | Out-Null
$whaleShortcut.Save()
Start-Process -FilePath $whaleLauncher -ArgumentList $whaleArgs -WorkingDirectory $DataDir -WindowStyle Hidden
$whaleNode = Find-WhaleNode
Invoke-WhaleCommand $whaleNode @((Join-Path $whaleRoot 'scripts\verify-runtime.mjs'),'--allow-idle')
@{installedAt=[DateTime]::UtcNow.ToString('o');launchMode='startup-folder';shortcut=$whaleLink;pluginRoot=$whaleRoot;verifiedRuntime=$true} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $DataDir 'follow-install.json') -Encoding UTF8
Write-Output 'Startup folder installation verified.'
