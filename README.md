# RepoReady AI v1.1 — One ZIP for a team new to GitHub Copilot

**Purpose:** Onboard an existing .NET repository to GitHub Copilot, even if it has no `.github` folder or AI configuration. Deliver two useful outcomes: **project-specific Copilot instructions** and a **Project Guide for new joiners**.

## What you need
- A Windows laptop with Windows PowerShell 5.1 or PowerShell 7.
- Your application repository already cloned locally.
- GitHub Copilot Chat in VS Code or Visual Studio, signed in with your organisation's approved account.
- You do **not** need Copilot CLI, Python, Node.js, APM, Teams, Power Automate or a new branch.
- Read/write permission for the application repository if you plan to apply the generated files.

## Start in five steps
1. Extract the ZIP to a folder **outside** your application repository.
2. Double-click **`Start-RepoReady.cmd`**.
3. Paste the local folder path to your application repository, for example `C:\work\MyApp`.
4. Review the automatically opened **`review.html`** summary. It reports detected technology, existing AI files, and proposed files. **The application repository has not been changed.**
5. In the RepoReady folder, copy the **preview and apply commands** printed by the launcher. Review, then apply the files to your current branch.

**Critical next step:** Open your application repository in VS Code or Visual Studio. In Copilot Chat, paste the contents of `.github/prompts/bootstrap-project.prompt.md`. Copilot then examines the actual code and improves the generated `copilot-instructions.md` and `project-overview.md`. Review the AI changes. Without this step, the output is only a metadata baseline, not a reliable explanation of the business application.

## What files appear in the application repository after Apply?
```
.github/
  copilot-instructions.md                  # baseline; personalise with Copilot Chat
  agents/project-guide.agent.md            # new joiner guide
  prompts/bootstrap-project.prompt.md      # one-time guided AI discovery
  prompts/discover-project.prompt.md       # repeatable read-only discovery
  instructions/dotnet.instructions.md      # .NET-specific rules (when .NET projects detected)
docs/ai/
  project-overview.md                      # baseline; enrich with verified source evidence
  README.md
```
Existing files are **never overwritten** by the installer. If they exist, manually merge changes.

## Where do reports go?
Inside the extracted kit:
```
output/<timestamp-random>/
  inventory.json                           # detected metadata
  readiness.json                           # presence-only heuristic
  review.html                              # offline visual summary
  staged/                                  # proposed files to install
  NEXT-STEPS.txt                           # exact commands for this run
  copilot-discovery-draft.md               # only when optional CLI is used
```
The reports stay outside the application repository. The readiness score is **not** a certification of AI quality.

## What does the launcher do?
1. Detects solution files, .NET project files, target frameworks and other language files.
2. Checks for existing Copilot instructions, Project Guide and project documentation.
3. Creates draft Copilot configuration and onboarding documents in a staging folder.
4. Creates an offline HTML report.
5. Shows the preview/apply commands. It does **not** commit, push, switch branches, overwrite existing files or invoke Copilot CLI by default.

## How to get project-specific instructions (essential)
Open the application repository in GitHub Copilot Chat and paste `.github/prompts/bootstrap-project.prompt.md`. The prompt asks Copilot to:
- Trace actual entry points, services, data access and representative business flows.
- Identify verified architecture, dependencies, tests and build instructions.
- Update `.github/copilot-instructions.md` and `docs/ai/project-overview.md`.
- Cite source paths and flag unknowns instead of inventing details.

Review the resulting Git diff and confirm its claims with the team. Do not assume a model can infer undocumented business intent perfectly.

## Test the new joiner experience
In supported Copilot Chat clients, select the **Project Guide** agent from the agent picker, or paste its Markdown instructions into Chat if unavailable. Ask:
> I'm new to this application. What does it do? Explain the main modules and trace one feature end to end. Cite real source files and give me a 30-minute onboarding plan.

Then ask a known feature question and verify the answer against the code.

## Existing branch and PRs
RepoReady uses whatever branch is currently checked out. It does **not** create or switch branches. For a clean review, a feature branch is recommended, but not required. Check `git status` before applying. After AI discovery and review, run team-approved build/tests and raise a normal PR.

## Optional Copilot CLI
The default onboarding path uses **Copilot Chat**, not CLI. If your team already has Copilot CLI installed and authenticated, you can optionally run:
```powershell
.\Start-RepoReady.ps1 -RepoPath "C:\work\MyApp" -UseCopilotCLI
```
This saves an extra AI-generated discovery draft for review. It does not run `copilot init` automatically. We deliberately avoid that command in v1.1 because it can write directly into the repository and conflicts with our safe preview-and-apply experience. You can run it separately in a reviewed branch if your client supports it and your team chooses to.

## Troubleshooting
| Issue | What to do |
|---|---|
| `.github` folder missing | Expected. Apply creates it. |
| `Start-RepoReady.cmd` fails | Try from PowerShell; consult IT if scripts are blocked by policy. |
| Invalid repository path | Clone the repository first, then paste its full local folder path. |
| Report doesn't open | Open `output/<run>/review.html` manually. It's static HTML. |
| Project overview doesn't explain the business | Run the bootstrap prompt in Copilot Chat and review its findings. |
| Custom agent doesn't appear | Reload IDE, check client support, or paste agent Markdown into Chat. |
| Existing instructions skipped | Merge manually; the installer never overwrites them. |
| No CLI | No problem; Copilot Chat is the default. |
| Copilot Chat cannot edit files | Ask for proposed Markdown and copy it into the two documents manually. |
| Readiness score seems inaccurate | It's a simple presence check, not a content quality assessment. |
| Repo is huge | Start with a small repo; metadata scan may take time; AI context limits require focused exploration. |

## Security and privacy
- Local metadata scans do not call an external AI endpoint.
- Copilot Chat and optional Copilot CLI use your organisation's configured Copilot service and may transmit code context; follow company policy.
- Never include credentials, secrets, customer records or production data in generated docs.
- The default launcher does not automatically execute application builds, install dependencies, or change application source.
- Only apply reviewed files. Do not blindly trust AI-generated business or architecture claims.

## What next?
See **`NEXT-STEPS.md`** for a short post-launch checklist and sample prompts. Use the generated Project Guide for onboarding, and add a dedicated BA requirement agent in a future release.
