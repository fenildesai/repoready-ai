# After launching RepoReady — developer quick guide

## 1. What just happened?
RepoReady detected repository metadata, produced a basic readiness report, and prepared proposed files under `output/<run>/staged`. **Nothing was copied to your application repository yet.** No new branch was created.

## 2. Review and install on your current branch
From the extracted RepoReady folder, copy the commands printed by the launcher:
```powershell
.\Apply-RepoReady.ps1 -RepoPath "C:\work\my-app" -RunPath ".\output\<your-run>" -WhatIf
.\Apply-RepoReady.ps1 -RepoPath "C:\work\my-app" -RunPath ".\output\<your-run>"
```
The installer adds missing files only and skips existing files. It does not commit, push, or change your active Git branch. If you have uncommitted changes, review them first; preferably use a feature branch.

## 3. Get actual application knowledge using Copilot Chat (default)
1. Open your application repository in VS Code or Visual Studio.
2. Sign into GitHub Copilot Chat and choose a mode that can read repository files and edit the two onboarding documents with your approval.
3. Open `.github/prompts/bootstrap-project.prompt.md`, copy its full contents into Copilot Chat, and send it.
4. Review the discovered business purpose, architecture and source references.
5. Allow only changes to `.github/copilot-instructions.md` and `docs/ai/project-overview.md` after review. If your client cannot edit, paste the draft changes manually.
6. Do **not** accept invented business functionality or guessed build commands.

## 4. Test Project Guide
In a Copilot client supporting repository custom agents, select **Project Guide** and ask:
> I'm new to this repository. Explain what the application does, the main components, and one feature flow. Show me exact source files to read.

If custom agents are unavailable, paste the contents of `.github/agents/project-guide.agent.md` into normal Copilot Chat.

## 5. Finish
Review `git status` and `git diff`; run team-approved checks; ask a maintainer to validate the overview; raise a PR. Share the Project Guide prompt and overview with new joiners.

## 6. Optional CLI
If your organisation has GitHub Copilot CLI installed, run:
```powershell
.\Start-RepoReady.ps1 -RepoPath "C:\work\my-app" -UseCopilotCLI
```
This creates an **additional AI discovery draft** under the output folder. It does **not** silently replace instructions. The default path requires **no CLI**.

## Troubleshooting
- **No `.github` folder:** normal; apply creates it.
- **Copilot Chat not available:** install/sign in using your organisation's approved method; baseline still works.
- **Agent not visible:** reload IDE; verify custom-agent support; use the agent Markdown as a Chat prompt.
- **Output report not opening:** open `output/<run>/review.html` manually in Edge or Chrome. It has no JavaScript or external resources.
- **Files skipped:** existing files are protected. Review and manually merge the proposed changes.
- **PowerShell blocked:** try `Start-RepoReady.cmd`; if organisation policy still blocks scripts, ask IT rather than weakening security settings.
- **Weak project overview:** the launcher only discovers metadata; complete the Copilot Chat bootstrap prompt and verify results.
