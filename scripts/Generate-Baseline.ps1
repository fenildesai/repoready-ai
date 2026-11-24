[CmdletBinding()]
param([Parameter(Mandatory)][string]$RepoPath,[Parameter(Mandatory)][string]$KitPath,[Parameter(Mandatory)][string]$OutputDir)
$ErrorActionPreference='Stop'
$inv=Get-Content -LiteralPath (Join-Path $OutputDir 'inventory.json') -Raw | ConvertFrom-Json
$stage=Join-Path $OutputDir 'staged'
New-Item -ItemType Directory -Path $stage -Force | Out-Null
function Save([string]$relative,[string]$content) {
 $path=Join-Path $stage $relative
 $parent=Split-Path -Parent $path
 if(!(Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
 $content | Set-Content -LiteralPath $path -Encoding UTF8
}
$framework=if(@($inv.targetFrameworks).Count){@($inv.targetFrameworks) -join ', '}else{'Not determined'}
$projectList=if(@($inv.projects).Count){(@($inv.projects | Select-Object -First 40) | ForEach-Object { "- ``$_``" }) -join "`r`n"}else{'No supported project files detected'}
$solutionList=if(@($inv.solutions).Count){(@($inv.solutions) -join ', ')}else{'Not detected'}
$instructions=@"
# Copilot instructions — RepoReady AI starter

This file is a **draft baseline**, generated from repository metadata. Review and enrich it with Copilot discovery before merging.

## Repository facts (scanner evidence)
- Detected target frameworks: $framework
- Solution files: $solutionList
- Project files are listed in ``docs/ai/project-overview.md``.

## Grounding and engineering rules
- Read existing repository code and documentation before answering.
- Refer to exact paths and symbols. Separate verified facts from assumptions.
- Never invent business capabilities, architecture, integration contracts, or build commands.
- Prefer established patterns in this repository over generic recommendations.
- For changes, first explain impact, acceptance criteria, risks, and relevant tests.
- Do not expose secrets, tokens, connection strings, customer information, or environment values.
- Do not modify application code, commit, push, deploy, or run destructive commands without explicit approval.
- Use ``docs/ai/project-overview.md`` as an orientation aid; verify important statements against code.
- When a detail is unknown, identify what evidence or owner confirmation is needed.
"@
Save '.github/copilot-instructions.md' $instructions
$overview=@"
# Project overview — RepoReady draft

> This is an automated **metadata baseline**. Business purpose and detailed architecture are **not yet verified**. Use Copilot discovery to enrich it.

## Repository inventory
- Detected target frameworks: $framework
- Solutions: $solutionList

## Project files
$projectList

## Business purpose
Not yet established from source evidence. Do not invent.

## Application entry points and request flow
Not yet verified. Investigate ``Program.cs``, ``Startup.cs``, controllers, services, and other entry points where relevant.

## Integrations and data access
Not yet verified.

## How to build, test and run
Not yet verified. Inspect repo README, pipelines, SDK files and test projects.

## New joiner path
1. Read this overview and repository README.
2. Review solution and project files.
3. Trace a real feature through entry points, business logic and persistence.
4. Verify build and test instructions with project maintainers.
5. Ask Project Guide to explain components with file references.

## Open questions
- What is the verified business purpose?
- Which application is the primary entry point?
- What are the verified local build/test steps?
"@
Save 'docs/ai/project-overview.md' $overview
foreach($name in @('project-guide.agent.md')) {
 $source=Join-Path $KitPath "templates\$name"
 Save ".github/agents/$name" (Get-Content -LiteralPath $source -Raw)
}
Save '.github/prompts/discover-project.prompt.md' (Get-Content -LiteralPath (Join-Path $KitPath 'templates\discover-project.prompt.md') -Raw)
Save '.github/prompts/bootstrap-project.prompt.md' (Get-Content -LiteralPath (Join-Path $KitPath 'templates\bootstrap-project.prompt.md') -Raw)
if (@($inv.projects).Count -gt 0) {
 Save '.github/instructions/dotnet.instructions.md' (Get-Content -LiteralPath (Join-Path $KitPath 'templates\dotnet.instructions.md') -Raw)
}

Save 'docs/ai/README.md' @'
# RepoReady AI documents
`project-overview.md` is a draft. Review it with project owners and verify claims against code.
Use the Project Guide custom agent in a supported Copilot client, or paste the discovery prompt into Copilot Chat.
Do not commit unverified business descriptions.
'@
Write-Host "Staged starter configuration: $stage"
