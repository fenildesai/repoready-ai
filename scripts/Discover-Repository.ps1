[CmdletBinding()]
param([Parameter(Mandatory)][string]$RepoPath,[Parameter(Mandatory)][string]$OutputPath)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path -LiteralPath $RepoPath).Path
function Rel([string]$s) { $s.Substring($repo.Length).TrimStart([char[]]@('\','/')).Replace('\','/') }
$files=@(Get-ChildItem -LiteralPath $repo -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
 $_.FullName -notmatch '[\\/](\.git|\.vs|bin|obj|node_modules|packages|TestResults|\.next|dist)[\\/]'
})
$projects=@($files | Where-Object { $_.Extension -in @('.csproj','.fsproj','.vbproj') })
$frameworks=@()
foreach($p in $projects | Select-Object -First 100) {
 try {
  $s=Get-Content -LiteralPath $p.FullName -Raw
  foreach($m in [regex]::Matches($s,'<TargetFrameworks?>([^<]+)</TargetFrameworks?>')) {
   $frameworks+=@($m.Groups[1].Value -split ';')
  }
 } catch {}
}
$types=[ordered]@{
 CSharp=@($files | Where-Object Extension -eq '.cs').Count
 TypeScript=@($files | Where-Object Extension -eq '.ts').Count
 JavaScript=@($files | Where-Object Extension -eq '.js').Count
 Python=@($files | Where-Object Extension -eq '.py').Count
 Java=@($files | Where-Object Extension -eq '.java').Count
}
$readme=@($files | Where-Object { $_.Name -match '^README(\..+)?$' } | Select-Object -First 10 | ForEach-Object { Rel $_.FullName })
$results=[ordered]@{
 generatedAt=(Get-Date).ToString('o')
 repository=$repo
 fileCount=$files.Count
 languageFileCounts=$types
 targetFrameworks=@($frameworks | Where-Object {$_} | Sort-Object -Unique)
 solutions=@($files | Where-Object { $_.Extension -in @('.sln','.slnx') } | ForEach-Object { Rel $_.FullName })
 projects=@($projects | ForEach-Object { Rel $_.FullName })
 possibleTestProjects=@($projects | Where-Object { $_.FullName -match '(?i)test|spec' } | ForEach-Object { Rel $_.FullName })
 readmes=$readme
 pipelines=@($files | Where-Object { $_.Name -match '^(azure-pipelines.*\.ya?ml|Jenkinsfile)$' -or (Rel $_.FullName) -match '^\.github/workflows/' } | ForEach-Object { Rel $_.FullName })
 existingAI=@($files | Where-Object { (Rel $_.FullName) -match '(^|/)(AGENTS\.md|copilot-instructions\.md|[^/]+\.agent\.md)$' } | ForEach-Object { Rel $_.FullName })
}
$results | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Detected $($projects.Count) projects; frameworks: $($results.targetFrameworks -join ', ')"
