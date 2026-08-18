param(
  [Parameter(Mandatory=$true)][string]$ApiBaseUrl
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here
if (-not (Test-Path "android\gradle\wrapper\gradle-wrapper.jar")) {
  & "$here\bootstrap_android_wrapper.ps1"
}
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=API_BASE_URL=$ApiBaseUrl
Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk"
