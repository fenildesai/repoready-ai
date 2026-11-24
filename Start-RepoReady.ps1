[CmdletBinding()]
param(
 [string]$RepoPath,
 [switch]$UseCopilotCLI,
 [switch]$NoOpen
)
$ErrorActionPreference = 'Stop'
$kit = $PSScriptRoot
Write-Host "`nRepoReady AI v1.1 - Simple Copilot onboarding" -ForegroundColor Cyan
Write-Host "No existing .github folder required.`n"
if (-not $RepoPath) { $RepoPath = Read-Host 'Paste the full path to your local application repository' }
if ([string]::IsNullOrWhiteSpace($RepoPath) -or !(Test-Path -LiteralPath $RepoPath -PathType Container)) {
 throw 'The selected repository folder does not exist. Clone/open your application repository locally, then retry.'
}
$repo=(Resolve-Path -LiteralPath $RepoPath).Path
if ($repo.TrimEnd('\','/') -eq $kit.TrimEnd('\','/')) { throw 'Choose your application repository, not the RepoReady folder.' }
$run = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + ([guid]::NewGuid().ToString('N').Substring(0,6))
$out=Join-Path $kit "output\$run"
New-Item -ItemType Directory -Force -Path $out | Out-Null
Write-Host '[1/4] Detecting repository technology and structure...'
& (Join-Path $kit 'scripts\Discover-Repository.ps1') -RepoPath $repo -OutputPath (Join-Path $out 'inventory.json')
Write-Host '[2/4] Checking current Copilot readiness...'
& (Join-Path $kit 'scripts\Assess-Readiness.ps1') -RepoPath $repo -OutputPath (Join-Path $out 'readiness.json')
Write-Host '[3/4] Preparing Copilot instructions, onboarding agent and bootstrap prompt...'
& (Join-Path $kit 'scripts\Generate-Baseline.ps1') -RepoPath $repo -KitPath $kit -OutputDir $out
$aiStatus='Copilot Chat next step (default)'
if ($UseCopilotCLI) {
 if (Get-Command copilot -ErrorAction SilentlyContinue) {
  Write-Host 'Optional Copilot CLI discovery requested...'
  try {
   & (Join-Path $kit 'scripts\Invoke-CopilotDiscovery.ps1') -RepoPath $repo -OutputDir $out
   $aiStatus='CLI draft saved; review before use'
  } catch {
   Write-Warning "Copilot CLI discovery failed: $($_.Exception.Message)"
   $aiStatus='CLI unavailable; use Copilot Chat'
  }
 } else {
  Write-Warning 'Copilot CLI not found; use Copilot Chat instead.'
  $aiStatus='CLI unavailable; use Copilot Chat'
 }
}
Write-Host '[4/4] Creating offline summary...'
& (Join-Path $kit 'scripts\Write-Review.ps1') -OutputDir $out -AIStatus $aiStatus
$next=@"
RepoReady prepared a safe proposal. Your application repository has NOT been changed.

STEP A - Preview the proposed files:
  .\Apply-RepoReady.ps1 -RepoPath "$repo" -RunPath "$out" -WhatIf

STEP B - Add the proposed files to your CURRENT branch (no commit or push):
  .\Apply-RepoReady.ps1 -RepoPath "$repo" -RunPath "$out"

STEP C - Open the repository in VS Code or Visual Studio with GitHub Copilot Chat.
  Open .github/prompts/bootstrap-project.prompt.md and paste its instructions into Copilot Chat.
  Ask Copilot to investigate the real source code and update docs/ai/project-overview.md
  and .github/copilot-instructions.md with VERIFIED project-specific information.

STEP D - Review the Git diff, verify facts, test Project Guide, then raise a PR.
See README.md and NEXT-STEPS.md for details and troubleshooting.

Assessment report: $out\review.html
"@
$next | Set-Content -LiteralPath (Join-Path $out 'NEXT-STEPS.txt') -Encoding UTF8
Write-Host "`n$next" -ForegroundColor Yellow
if (!$NoOpen) { try { Invoke-Item (Join-Path $out 'review.html') } catch { Write-Warning 'Could not open report automatically; open review.html manually.' } }
