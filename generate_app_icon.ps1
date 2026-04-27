# Script to generate a simple app icon for DishDiary
# This creates a 1024x1024 PNG with blue background and "DD" text

Add-Type -AssemblyName System.Drawing

# Create bitmap
$bmp = New-Object System.Drawing.Bitmap(1024, 1024)
$graphics = [System.Drawing.Graphics]::FromImage($bmp)

# Fill background with gradient (blue theme)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, 1024, 1024)),
    [System.Drawing.Color]::FromArgb(25, 118, 210),
    [System.Drawing.Color]::FromArgb(66, 165, 245),
    45
)
$graphics.FillRectangle($brush, 0, 0, 1024, 1024)

# Add "DD" text in white
$font = New-Object System.Drawing.Font("Arial", 400, [System.Drawing.FontStyle]::Bold)
$textBrush = [System.Drawing.Brushes]::White
$text = "DD"

# Measure and center text
$stringFormat = New-Object System.Drawing.StringFormat
$stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

$layoutRect = New-Object System.Drawing.RectangleF(0, 0, 1024, 1024)
$graphics.DrawString($text, $font, $textBrush, $layoutRect, $stringFormat)

# Save
$outputPath = Join-Path $PSScriptRoot "assets\app_icon.png"
$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Cleanup
$graphics.Dispose()
$bmp.Dispose()
$brush.Dispose()
$font.Dispose()

Write-Host "App icon created successfully at: $outputPath"
Write-Host "Now run: dart run flutter_launcher_icons"
