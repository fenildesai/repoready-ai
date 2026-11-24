---
description: "Turn RepoReady's metadata baseline into verified, project-specific Copilot instructions and onboarding knowledge"
---
# RepoReady — Discover and personalise this repository

You are working inside the CURRENT application repository, not the RepoReady toolkit.

## Goal
Understand the actual application and improve the two files:
- `.github/copilot-instructions.md`
- `docs/ai/project-overview.md`

Do not ask the developer to describe the project if its purpose can be established from code and existing documentation.

## Investigation
1. Read existing README and docs, solution/project files, build pipelines, package manifests, and relevant entry points.
2. Identify real business capabilities by tracing controllers/pages/handlers through services and data access. Do not infer business purpose from project names alone.
3. Map application boundaries, target frameworks, dependencies, persistence, integrations, test projects and likely build/test commands.
4. For each important statement, cite a repository path and preferably a symbol. Separate verified facts, reasonable hypotheses and unknowns.
5. Avoid `.git`, `bin`, `obj`, generated files, secrets, credentials, customer records and unrelated files.

## Update the two files
- Replace placeholders in `docs/ai/project-overview.md` with an evidence-based onboarding guide, including what the application does, major components, one example request flow, first-day learning path and known unknowns.
- Improve `.github/copilot-instructions.md` with *actual* repository conventions, architectural constraints and safe engineering rules.
- Preserve existing instructions and do not overwrite unrelated files.
- Do not change application code, run deployments, install dependencies, commit or push.
- If you cannot verify a claim, mark it `Needs confirmation` instead of inventing it.

## Finish
Summarise changed files, key findings, uncertain claims and three example questions a new joiner can ask Project Guide. Ask the developer to review the Git diff.
