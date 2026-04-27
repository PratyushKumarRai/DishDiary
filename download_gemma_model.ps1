# Gemma 4 E2B Model Installation Helper
# This script helps you download and install the Gemma 4 E2B model for DishDiary

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Gemma 4 E2B Model Installer for DishDiary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$ModelUrl = "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"
$ModelFileName = "gemma-4-E2B-it.litertlm"
$TempDownloadPath = "$env:TEMP\$ModelFileName"

Write-Host "IMPORTANT: This model requires license acceptance on Hugging Face." -ForegroundColor Yellow
Write-Host ""
Write-Host "Before continuing, please:" -ForegroundColor Yellow
Write-Host "1. Visit: https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm" -ForegroundColor Yellow
Write-Host "2. Click 'Agree' to accept the Gemma license" -ForegroundColor Yellow
Write-Host "3. Ensure you are logged into Hugging Face" -ForegroundColor Yellow
Write-Host ""

$confirmed = Read-Host "Have you accepted the license? (y/n)"
if ($confirmed -ne "y") {
    Write-Host "Please accept the license first. Aborting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 1: Downloading model (~2.58GB)..." -ForegroundColor Green
Write-Host "This may take 15-30 minutes depending on your internet speed." -ForegroundColor Yellow
Write-Host ""

try {
    # Download the model
    $ProgressPreference = 'Continue'
    Invoke-WebRequest -Uri $ModelUrl -OutFile $TempDownloadPath -UseBasicParsing
    
    Write-Host ""
    Write-Host "✓ Download complete!" -ForegroundColor Green
    Write-Host "  File: $TempDownloadPath" -ForegroundColor Gray
    Write-Host "  Size: $([math]::Round((Get-Item $TempDownloadPath).Length / 1MB, 2)) MB" -ForegroundColor Gray
} catch {
    Write-Host ""
    Write-Host "✗ Download failed!" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "This might be because:" -ForegroundColor Yellow
    Write-Host "  1. You haven't accepted the license on Hugging Face" -ForegroundColor Yellow
    Write-Host "  2. You're not logged into Hugging Face" -ForegroundColor Yellow
    Write-Host "  3. The URL has changed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please visit the model page and download manually:" -ForegroundColor Yellow
    Write-Host "https://huggingface.co/litert-community/Gemma2-2B-IT" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "Step 2: Finding your Android device..." -ForegroundColor Green
Write-Host ""

# Check if device is connected
$adbOutput = & adb devices 2>&1
if ($adbOutput -match "device$") {
    Write-Host "✓ Android device connected!" -ForegroundColor Green
} else {
    Write-Host "✗ No Android device found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To install on your device:" -ForegroundColor Yellow
    Write-Host "1. Enable USB debugging on your Android device" -ForegroundColor Yellow
    Write-Host "2. Connect via USB" -ForegroundColor Yellow
    Write-Host "3. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual installation path:" -ForegroundColor Yellow
    Write-Host "/sdcard/Download/$ModelFileName" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "Step 3: Installing model to device..." -ForegroundColor Green
Write-Host ""

# Create Download directory on device
& adb shell "mkdir -p /sdcard/Download/"

# Push the model to external storage (app will copy to internal on first run)
& adb push $TempDownloadPath "/sdcard/Download/$ModelFileName"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Model installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Open the DishDiary app" -ForegroundColor White
    Write-Host "2. The app will automatically detect and install the model" -ForegroundColor White
    Write-Host "3. Wait ~5 minutes for the first-time installation" -ForegroundColor White
    Write-Host "4. Go to Settings to verify status shows 'Installed'" -ForegroundColor White
    Write-Host "5. Try the AI Recipe Chef!" -ForegroundColor White
    Write-Host ""
    
    # Cleanup temp file
    $cleanup = Read-Host "Delete temporary download? (y/n)"
    if ($cleanup -eq "y") {
        Remove-Item $TempDownloadPath
        Write-Host "✓ Temporary file deleted" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "✗ Installation failed!" -ForegroundColor Red
    Write-Host "  Try restarting your device and running this script again" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Gemma 4 E2B Installation Complete! 🎉" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
