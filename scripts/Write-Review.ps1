[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputDir,[string]$AIStatus='not run')
$ErrorActionPreference='Stop'
$inv=Get-Content (Join-Path $OutputDir 'inventory.json') -Raw | ConvertFrom-Json
$read=Get-Content (Join-Path $OutputDir 'readiness.json') -Raw | ConvertFrom-Json
$files=@(Get-ChildItem (Join-Path $OutputDir 'staged') -Recurse -File | ForEach-Object { $_.FullName.Substring((Join-Path $OutputDir 'staged').Length).TrimStart([char[]]@('\','/')).Replace('\','/') })
$escape={param($s) [System.Net.WebUtility]::HtmlEncode([string]$s)}
$rows=($files | ForEach-Object { '<li><code>'+(& $escape $_)+'</code></li>' }) -join "`n"
$checks=(@($read.checks) | ForEach-Object {
 $state=if($_.passed){'Present'}else{'Missing'}
 '<tr><td>'+(& $escape $_.name)+'</td><td>'+(& $escape $state)+'</td><td>'+($_.weight)+'</td></tr>'
}) -join "`n"
$html=@"
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>RepoReady AI — Review</title><style>
body{font:16px system-ui,Segoe UI,sans-serif;background:#0e1728;color:#e9f1ff;margin:0}
main{max-width:950px;margin:auto;padding:32px 22px}h1{font-size:34px}h2{margin-top:28px}
.card{background:#182840;border:1px solid #37506f;border-radius:14px;padding:22px;margin:16px 0}
small,p{color:#bdcce3;line-height:1.55}strong{color:#93c5fd}code{color:#b7dbff}
table{border-collapse:collapse;width:100%}td,th{text-align:left;border-bottom:1px solid #3c526f;padding:10px}
a{color:#93c5fd}button{background:#2563eb;color:white;border:0;border-radius:9px;padding:12px;cursor:pointer}
</style></head><body><main><h1>RepoReady AI — Assessment &amp; Review</h1>
<p>Local report generated from repository metadata. This page is read-only and works offline.</p>
<div class="card"><h2>Readiness</h2><p><strong style="font-size:44px">$($read.score)/100</strong></p>
<p>Presence-only heuristic, not a quality score.</p><table><tr><th>Category</th><th>Found</th><th>Weight</th></tr>$checks</table></div>
<div class="card"><h2>Repository discovery</h2><p>Target frameworks: <strong>$(& $escape (@($inv.targetFrameworks) -join ', '))</strong></p>
<p>Projects: $(@($inv.projects).Count) · Solutions: $(@($inv.solutions).Count) · Scanned files: $($inv.fileCount)</p>
<p>Copilot CLI enrichment: <strong>$(& $escape $AIStatus)</strong></p></div>
<div class="card"><h2>Generated files — staged, not installed</h2><ul>$rows</ul>
<p>Open the <code>staged</code> folder to review the drafts. If Copilot discovery ran, also review <code>copilot-discovery-draft.md</code> and use verified findings to enrich the overview and instructions.</p></div>
<div class="card"><h2>Next steps</h2><ol><li>Review generated content and confirm it against source.</li>
<li>Run <code>Apply-RepoReady.ps1</code> with <code>-WhatIf</code>, then without it, using paths shown in the launcher.</li>
<li>Open the repo in VS Code, select Project Guide if supported, and ask it to explain the application with file evidence.</li>
<li>Review git diff, run your normal checks, and create a pull request.</li></ol></div>
<p><small>This page intentionally does not execute commands or access the file system.</small></p>
</main></body></html>
"@
$html | Set-Content -LiteralPath (Join-Path $OutputDir 'review.html') -Encoding UTF8
Write-Host "Offline review page generated: $(Join-Path $OutputDir 'review.html')"
