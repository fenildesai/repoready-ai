[CmdletBinding()]
param([Parameter(Mandatory)][string]$RepoPath,[Parameter(Mandatory)][string]$OutputPath)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path -LiteralPath $RepoPath).Path
function Has([string]$p) { Test-Path -LiteralPath (Join-Path $repo $p) }
$checks=@(
 [ordered]@{ name='Copilot instructions'; passed=((Has '.github/copilot-instructions.md') -or (Has 'AGENTS.md')); weight=25 },
 [ordered]@{ name='Project overview / README'; passed=((Has 'README.md') -or (Has 'docs/ai/project-overview.md')); weight=25 },
 [ordered]@{ name='Architecture guidance'; passed=((Has 'ARCHITECTURE.md') -or (Has 'docs/architecture.md') -or (Has 'docs/ai/project-overview.md')); weight=20 },
 [ordered]@{ name='Project Guide agent'; passed=(Has '.github/agents/project-guide.agent.md'); weight=20 },
 [ordered]@{ name='Build/test documentation'; passed=((Has 'CONTRIBUTING.md') -or (Has 'docs/build.md') -or (Has 'docs/testing.md')); weight=10 }
)
$score=0
foreach($c in $checks) { if($c.passed) { $score += $c.weight } }
[ordered]@{
 score=$score
 maximum=100
 methodology='Presence-only heuristic. Not a quality assessment; evidence must be reviewed.'
 checks=$checks
} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Readiness presence score: $score/100"
