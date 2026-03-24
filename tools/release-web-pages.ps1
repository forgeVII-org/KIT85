param(
    [string]$BaseHref = '/KIT85/app/'
)

$ErrorActionPreference = 'Stop'

# Always run from repository root regardless of invocation directory.
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

if (-not $BaseHref.StartsWith('/')) {
    throw "BaseHref must start with '/'. Example: /KIT85/app/"
}
if (-not $BaseHref.EndsWith('/')) {
    throw "BaseHref must end with '/'. Example: /KIT85/app/"
}

Write-Host '==> Running flutter analyze'
flutter analyze

Write-Host "==> Building web release with base href: $BaseHref"
flutter build web --release --base-href $BaseHref

$webBuildPath = Join-Path $repoRoot 'build\web'
if (-not (Test-Path $webBuildPath)) {
    throw "Web build completed but output folder not found: $webBuildPath"
}

$pagesAppPath = Join-Path $repoRoot 'docs\app'
if (Test-Path $pagesAppPath) {
    Remove-Item -Recurse -Force $pagesAppPath
}
New-Item -ItemType Directory -Path $pagesAppPath | Out-Null

Copy-Item -Path (Join-Path $webBuildPath '*') -Destination $pagesAppPath -Recurse -Force

Write-Host "==> Web app ready for GitHub Pages: $pagesAppPath"
Write-Host '==> Commit docs/app and push to main to publish.'
Write-Host '==> Expected app URL: https://forgevii-org.github.io/KIT85/app/'
