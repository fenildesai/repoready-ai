[CmdletBinding()]
param([Parameter(Mandatory)][string]$RepoPath,[Parameter(Mandatory)][string]$OutputDir)
$ErrorActionPreference='Stop'
$prompt=Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\templates\copilot-discovery.txt') -Raw
$original=Get-Location
$target=Join-Path $OutputDir 'copilot-discovery-draft.md'
try {
 Set-Location -LiteralPath $RepoPath
 # GitHub Copilot CLI non-interactive prompt mode. No auto-approval flags are passed.
 # Output is saved OUTSIDE the repository and requires human review.
 $response = & copilot -p $prompt 2>&1
 $exit=$LASTEXITCODE
 $text=@($response | ForEach-Object { "$_" }) -join [Environment]::NewLine
 $text | Set-Content -LiteralPath $target -Encoding UTF8
 if($exit -ne 0) { throw "Copilot CLI exited with code $exit. See $target" }
 if([string]::IsNullOrWhiteSpace($text)) { throw 'Copilot CLI returned no text.' }
 Write-Host "AI discovery draft saved: $target"
} finally { Set-Location $original }
