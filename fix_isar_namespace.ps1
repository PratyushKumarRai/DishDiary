# Fix Isar namespace issue for AGP 8.x compatibility
$isarBuildGradle = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle"
$isarAndroidManifest = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\src\main\AndroidManifest.xml"

Write-Host "Patching Isar build.gradle at: $isarBuildGradle"

if (-not (Test-Path $isarBuildGradle)) {
    Write-Error "Could not find isar_flutter_libs build.gradle. Please run 'flutter pub get' first."
    exit 1
}

# Patch build.gradle - add namespace inside android block
$content = Get-Content $isarBuildGradle -Raw
$patchedContent = $content -replace 'android \{', "android {`n        namespace 'com.isar.isar_flutter_libs'"
Set-Content $isarBuildGradle $patchedContent -NoNewline

Write-Host "Patched build.gradle"

# Patch AndroidManifest.xml - remove package attribute
if (Test-Path $isarAndroidManifest) {
    $manifestContent = Get-Content $isarAndroidManifest -Raw
    $patchedManifest = $manifestContent -replace ' package="[^"]*"', ''
    Set-Content $isarAndroidManifest $patchedManifest -NoNewline
    Write-Host "Patched AndroidManifest.xml"
}

Write-Host "Done! Please rebuild your project with 'flutter run'"
