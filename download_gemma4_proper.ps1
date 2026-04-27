# Download Gemma 4 E2B model with proper handling for large files
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Gemma 4 E2B Downloader (2.58 GB)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ModelFileName = "gemma-4-E2B-it.litertlm"
$OutputPath = "$env:TEMP\$ModelFileName"

# Check if file already exists and check its size
if (Test-Path $OutputPath) {
    $currentSize = (Get-Item $OutputPath).Length
    $currentSizeGB = [math]::Round($currentSize / 1GB, 2)
    Write-Host "Existing file found: $currentSizeGB GB" -ForegroundColor Yellow
    
    if ($currentSizeGB -ge 2.5 -and $currentSizeGB -le 2.7) {
        Write-Host "File size looks good! Using existing file." -ForegroundColor Green
    } else {
        Write-Host "File size is wrong ($currentSizeGB GB instead of ~2.58 GB)" -ForegroundColor Red
        $choice = Read-Host "Delete and re-download? (y/n)"
        if ($choice -eq "y") {
            Remove-Item $OutputPath -Force
            Write-Host "Deleted. Will re-download." -ForegroundColor Green
        } else {
            Write-Host "Keeping existing file (may fail)." -ForegroundColor Yellow
        }
    }
}

# Download if needed
if (-not (Test-Path $OutputPath)) {
    Write-Host ""
    Write-Host "Downloading gemma-4-E2B-it.litertlm (~2.58 GB)..." -ForegroundColor Green
    Write-Host "This will take 10-30 minutes depending on your internet speed." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Use BITS for reliable large file downloads on Windows
        $BitsJob = Start-BitsTransfer -Source "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm" -Destination $OutputPath -DisplayName "Gemma 4 E2B Download" -Description "Downloading Gemma 4 E2B model for DishDiary" -Asynchronous
        
        Write-Host "Download started..." -ForegroundColor Cyan
        Write-Host ""
        
        # Monitor progress
        while ($BitsJob.JobState -eq "Transferring" -or $BitsJob.JobState -eq "Connecting") {
            $progress = [math]::Round(($BitsJob.BytesTransferred / $BitsJob.BytesTotal) * 100, 1)
            $mbTransferred = [math]::Round($BitsJob.BytesTransferred / 1MB, 0)
            $mbTotal = [math]::Round($BitsJob.BytesTotal / 1MB, 0)
            Write-Host "`r  Progress: $progress% ($mbTransferred / $mbTotal MB)" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Seconds 2
        }
        
        Write-Host ""
        
        if ($BitsJob.JobState -eq "Transferred") {
            Complete-BitsTransfer -BitsJob $BitsJob
            Write-Host ""
            Write-Host "Download complete!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "Download failed with state: $($BitsJob.JobState)" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host ""
        Write-Host "Download error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Alternative: Download manually from:" -ForegroundColor Yellow
        Write-Host "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm" -ForegroundColor Cyan
        exit 1
    }
}

# Verify file size
if (Test-Path $OutputPath) {
    $fileSize = (Get-Item $OutputPath).Length
    $fileSizeGB = [math]::Round($fileSize / 1GB, 2)
    
    Write-Host ""
    Write-Host "File saved to: $OutputPath" -ForegroundColor Green
    Write-Host "File size: $fileSizeGB GB" -ForegroundColor $(if ($fileSizeGB -ge 2.5 -and $fileSizeGB -le 2.7) { "Green" } else { "Red" })
    
    if ($fileSizeGB -lt 2.5 -or $fileSizeGB -gt 2.7) {
        Write-Host ""
        Write-Host "WARNING: File size is not ~2.58 GB as expected!" -ForegroundColor Red
        Write-Host "The model may be corrupted or incomplete." -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Next step: Push to your Android device" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Using ADB:" -ForegroundColor Cyan
    Write-Host "  `"C:\Users\Pratyush\AppData\Local\Android\Sdk\platform-tools\adb.exe`" push `"$OutputPath`" `"/sdcard/Download/$ModelFileName`"" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "File not found after download!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Read-Host "Press Enter to exit"
