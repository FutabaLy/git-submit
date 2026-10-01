param([string]$Destination)
$ErrorActionPreference='Stop'
$whaleSource=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if(!$Destination){$Destination=Join-Path (Split-Path -Parent $whaleSource) 'DeepSeek-Codex-Whale-source.zip'}
$Destination=[IO.Path]::GetFullPath($Destination)
if($Destination.StartsWith($whaleSource+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Choose a ZIP destination outside the project.'}
if(Test-Path -LiteralPath $Destination){throw 'Destination already exists; choose a new ZIP name.'}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$whaleZip=[IO.Compression.ZipFile]::Open($Destination,'Create')
try{
    foreach($whaleFile in Get-ChildItem -LiteralPath $whaleSource -File -Recurse -Force){
        $whaleRelative=$whaleFile.FullName.Substring($whaleSource.Length+1).Replace('\','/')
        if($whaleRelative -match '(^|/)(\.git|node_modules|dist|qa[^/]*|backups|local-backups|desktop-runtime|desktop-profile|whale-widget|\.codex|__pycache__)(/|$)'){continue}
        if($whaleRelative -match '(^|/)(\.env[^/]*|credential\.json|auth\.json|api-settings\.json|runtime\.json|ui-state\.json|balance-source\.json|last-turn\.json|follow-[^/]+\.json|launcher-[^/]+\.json|supervisor-[^/]+\.json|ledger[^/]*\.json|[^/]+-installation\.json)$'){continue}
        if($whaleRelative -match '\.(zip|log|tmp|bak|jsonl|sqlite[^/]*|db|pem|key|pfx|mp4)$'){continue}
        if($whaleRelative.StartsWith('sources/deepseek/')){continue}
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($whaleZip,$whaleFile.FullName,('DeepSeek-Codex-Whale/'+$whaleRelative),'Optimal') | Out-Null
    }
} finally {$whaleZip.Dispose()}
$whaleHash=(Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash.ToLowerInvariant()
($whaleHash+'  '+[IO.Path]::GetFileName($Destination)) | Set-Content -LiteralPath ($Destination+'.sha256') -Encoding ASCII
Write-Output ('Created '+[IO.Path]::GetFileName($Destination))
