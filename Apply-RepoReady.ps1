[CmdletBinding(SupportsShouldProcess=$true)]
param(
 [Parameter(Mandatory=$true)][string]$RepoPath,
 [Parameter(Mandatory=$true)][string]$RunPath
)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path -LiteralPath $RepoPath).Path
$run=(Resolve-Path -LiteralPath $RunPath).Path
$stage=Join-Path $run 'staged'
if (!(Test-Path -LiteralPath $stage -PathType Container)) { throw "Staged directory missing. Use the output folder created by the launcher." }
$files=@(Get-ChildItem -LiteralPath $stage -File -Recurse)
if (!$files.Count) { throw 'No staged files found.' }
foreach($file in $files) {
 $relative=$file.FullName.Substring($stage.Length).TrimStart([char[]]@('\','/'))
 $dest=Join-Path $repo $relative
 if(Test-Path -LiteralPath $dest) { Write-Warning "SKIPPED existing file: $relative"; continue }
 if($PSCmdlet.ShouldProcess($dest,'Install reviewed RepoReady file')) {
  $parent=Split-Path -Parent $dest
  if(!(Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
  Copy-Item -LiteralPath $file.FullName -Destination $dest
  Write-Host "Installed: $relative" -ForegroundColor Green
 }
}
Write-Host 'Finished. Review git diff, test with Copilot, and create a PR.'
