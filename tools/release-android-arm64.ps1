$ErrorActionPreference = 'Stop'

# Always run from repository root regardless of invocation directory.
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

$keyPropsPath = Join-Path $repoRoot 'android\key.properties'
if (-not (Test-Path $keyPropsPath)) {
    throw "Missing android/key.properties. Create it from android/key.properties.example before running production release builds."
}

Write-Host '==> Running flutter analyze'
flutter analyze

Write-Host '==> Building hardened arm64 release APK'
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=build/debug-info --tree-shake-icons

$apkPath = Join-Path $repoRoot 'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path $apkPath)) {
    throw "Build completed but APK not found at expected path: $apkPath"
}

$apk = Get-Item $apkPath
$sizeMb = [math]::Round($apk.Length / 1MB, 2)
Write-Host "==> APK ready: $($apk.FullName)"
Write-Host "==> Size: $sizeMb MB"

$apksigner = Get-Command apksigner -ErrorAction SilentlyContinue
if ($apksigner) {
    Write-Host '==> Verifying APK signature (apksigner)'
    & $apksigner.Source verify --print-certs $apkPath
} else {
    Write-Host '==> apksigner not found in PATH. Verify manually with Android build-tools apksigner.'
}

Write-Host '==> Keep build/debug-info private for symbolication.'
