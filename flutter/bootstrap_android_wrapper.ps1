$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$temp = Join-Path $env:TEMP ("fitin_flutter_scaffold_" + [guid]::NewGuid().ToString())
flutter create --platforms=android --org com.larc --project-name smart_recipe_nutrition_app $temp
Copy-Item (Join-Path $temp "android\gradlew") (Join-Path $here "android\gradlew") -Force
Copy-Item (Join-Path $temp "android\gradlew.bat") (Join-Path $here "android\gradlew.bat") -Force
New-Item -ItemType Directory -Force -Path (Join-Path $here "android\gradle\wrapper") | Out-Null
Copy-Item (Join-Path $temp "android\gradle\wrapper\gradle-wrapper.jar") (Join-Path $here "android\gradle\wrapper\gradle-wrapper.jar") -Force
Remove-Item $temp -Recurse -Force
Write-Host "Android Gradle wrapper installed without replacing FITIN Android configuration."
