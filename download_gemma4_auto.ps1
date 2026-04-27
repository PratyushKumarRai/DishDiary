# Auto-download Gemma 4 E2B Model (no prompts)
# This script downloads and pushes the model to your Android device

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Gemma 4 E2B Auto-Downloader" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$ModelUrl = "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"
$ModelFileName = "gemma-4-E2B-it.litertlm"
$TempDownloadPath = "$env:TEMP\$ModelFileName"

# Check if model already exists
if (Test-Path $TempDownloadPath) {
    $fileSize = (Get-Item $TempDownloadPath).Length
    Write-Host "Found existing file: $([math]::Round($fileSize / 1GB, 2)) GB" -ForegroundColor Yellow
    $response = Read-Host "Delete and re-download? (y/n)"
    if ($response -eq "y") {
        Remove-Item $TempDownloadPath
    } else {
        Write-Host "Using existing file." -ForegroundColor Green
        $skipDownload = $true
    }
}

# Download the model
if (-not $skipDownload) {
    Write-Host ""
    Write-Host "Downloading model (~2.58GB)..." -ForegroundColor Green
    Write-Host "This may take 15-30 minutes." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $ModelUrl -OutFile $TempDownloadPath -UseBasicParsing
        
        Write-Host ""
        Write-Host "Download complete!" -ForegroundColor Green
        Write-Host "  File: $TempDownloadPath" -ForegroundColor Gray
        Write-Host "  Size: $([math]::Round((Get-Item $TempDownloadPath).Length / 1GB, 2)) GB" -ForegroundColor Gray
    } catch {
        Write-Host ""
        Write-Host "Download failed!" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Visit this URL and download manually:" -ForegroundColor Yellow
        Write-Host "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm" -ForegroundColor Cyan
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "Model file is at: $TempDownloadPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Transfer to your Android device's /sdcard/Download/ folder" -ForegroundColor Yellow
Write-Host "  Option 1: USB cable - copy manually" -ForegroundColor Gray
Write-Host "  Option 2: ADB - run: adb push `"$TempDownloadPath`" `"/sdcard/Download/$ModelFileName`"" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to exit"
