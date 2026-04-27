# Script to generate app icon with restaurant_menu icon for DishDiary
Add-Type -AssemblyName System.Drawing

# Create bitmap
$bmp = New-Object System.Drawing.Bitmap(1024, 1024)
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Fill background with gradient (blue theme like home screen)
$rect = New-Object System.Drawing.Rectangle(0, 0, 1024, 1024)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(25, 118, 210),
    [System.Drawing.Color]::FromArgb(66, 165, 245),
    45
)
$graphics.FillRectangle($brush, $rect)

# Draw restaurant_menu icon (leaf/restaurant symbol)
# This is a simplified version of the material Icons.restaurant_menu
$pen = New-Object System.Drawing.Pen([System.Drawing.Brushes]::White, 40)
$pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

# Main leaf shape (similar to restaurant_menu icon)
$points = @(
    (New-Object System.Drawing.PointF(512, 150)),    # Top center
    (New-Object System.Drawing.PointF(750, 250)),    # Top right
    (New-Object System.Drawing.PointF(850, 500)),    # Middle right
    (New-Object System.Drawing.PointF(700, 750)),    # Bottom right
    (New-Object System.Drawing.PointF(512, 850)),    # Bottom center
    (New-Object System.Drawing.PointF(324, 750)),    # Bottom left
    (New-Object System.Drawing.PointF(174, 500)),    # Middle left
    (New-Object System.Drawing.PointF(274, 250))     # Top left
)

# Fill the leaf shape
$leafBrush = [System.Drawing.Brushes]::White
$graphics.FillPolygon($leafBrush, $points, [System.Drawing.Drawing2D.FillMode]::Winding)

# Add a small stem at the top
$stemPen = New-Object System.Drawing.Pen([System.Drawing.Brushes]::White, 50)
$stemPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$graphics.DrawLine($stemPen, 512, 150, 512, 80)

# Add a subtle circle around the icon for better visibility
$circlePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 8)
$circlePen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Solid
$graphics.DrawEllipse($circlePen, 120, 120, 784, 784)

# Save
$outputPath = Join-Path $PSScriptRoot "assets\app_icon.png"
$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Cleanup
$graphics.Dispose()
$bmp.Dispose()
$brush.Dispose()
$pen.Dispose()
$stemPen.Dispose()
$circlePen.Dispose()

Write-Host "Restaurant menu app icon created successfully at: $outputPath"
Write-Host "Now run: dart run flutter_launcher_icons"
