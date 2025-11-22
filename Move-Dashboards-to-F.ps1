# ============================================================================
# MOVE DASHBOARDS TO F:\ DRIVE
# ============================================================================
# Automatically moves all Mazeflix dashboards to organized F:\ structure
# Author: Willie (Blkmaze)
# ============================================================================

param(
    [string]$SourcePath = "$env:USERPROFILE\Desktop",
    [string]$DestDrive = "F:",
    [switch]$WhatIf
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-Host ""
    Write-ColorOutput "╔════════════════════════════════════════════════════════════╗" "Red"
    Write-ColorOutput "║     MAZEFLIX DASHBOARD MIGRATION TO F:\                   ║" "Red"
    Write-ColorOutput "╚════════════════════════════════════════════════════════════╝" "Red"
    Write-Host ""
}

Show-Banner

# Check if F:\ exists
if (!(Test-Path $DestDrive)) {
    Write-ColorOutput "✗ F:\ drive not found!" "Red"
    Write-ColorOutput "Please setup F:\ drive first using Setup-F-Drive.bat" "Yellow"
    exit 1
}

# Check if structure exists
$requiredFolders = @("Unified", "System-Admin", "Scripts\PowerShell", "Documentation")
$missingFolders = @()

foreach ($folder in $requiredFolders) {
    if (!(Test-Path "$DestDrive\$folder")) {
        $missingFolders += $folder
    }
}

if ($missingFolders.Count -gt 0) {
    Write-ColorOutput "⚠ Missing folders on F:\" "Yellow"
    Write-ColorOutput "Please run Setup-F-Drive.bat first" "Yellow"
    Write-Host ""
    Write-ColorOutput "Missing: $($missingFolders -join ', ')" "Red"
    
    $create = Read-Host "Create missing folders now? (Y/N)"
    if ($create -eq 'Y') {
        foreach ($folder in $missingFolders) {
            New-Item -Path "$DestDrive\$folder" -ItemType Directory -Force | Out-Null
            Write-ColorOutput "✓ Created: $folder" "Green"
        }
    } else {
        exit 1
    }
}

Write-ColorOutput "[MIGRATION PLAN]" "Cyan"
Write-ColorOutput "=" * 70 "Gray"

# Define file mapping
$fileMapping = @(
    @{
        Source = "Mazeflix-Control-Center.html"
        Destination = "Unified\Mazeflix-Control-Center.html"
        Category = "Unified Dashboard"
    },
    @{
        Source = "Drive-Organization-Manager.html"
        Destination = "System-Admin\Drive-Organization-Manager.html"
        Category = "System Administration"
    },
    @{
        Source = "Mazeflix-Migration-Script.ps1"
        Destination = "Scripts\PowerShell\Mazeflix-Migration-Script.ps1"
        Category = "PowerShell Scripts"
    },
    @{
        Source = "Migration-Quick-Guide.md"
        Destination = "Documentation\Migration-Quick-Guide.md"
        Category = "Documentation"
    },
    @{
        Source = "F-Drive-Setup-Guide.md"
        Destination = "Documentation\F-Drive-Setup-Guide.md"
        Category = "Documentation"
    },
    @{
        Source = "Setup-Dashboard-Hub.ps1"
        Destination = "Scripts\PowerShell\Setup-Dashboard-Hub.ps1"
        Category = "PowerShell Scripts"
    },
    @{
        Source = "Setup-F-Drive.bat"
        Destination = "Scripts\Setup-F-Drive.bat"
        Category = "Setup Scripts"
    }
)

$found = 0
$notFound = 0
$moved = 0

# Check what files exist
foreach ($file in $fileMapping) {
    $sourcePath = Join-Path $SourcePath $file.Source
    $destPath = Join-Path $DestDrive $file.Destination
    
    if (Test-Path $sourcePath) {
        Write-ColorOutput "✓ Found: $($file.Source)" "Green"
        Write-ColorOutput "  → Moving to: $($file.Destination)" "Gray"
        $found++
        
        if (!$WhatIf) {
            try {
                # Create destination directory if needed
                $destDir = Split-Path $destPath -Parent
                if (!(Test-Path $destDir)) {
                    New-Item -Path $destDir -ItemType Directory -Force | Out-Null
                }
                
                # Copy file (keep original as backup)
                Copy-Item -Path $sourcePath -Destination $destPath -Force
                Write-ColorOutput "  ✓ Copied successfully" "Green"
                $moved++
            } catch {
                Write-ColorOutput "  ✗ Failed: $($_.Exception.Message)" "Red"
            }
        }
    } else {
        Write-ColorOutput "✗ Not found: $($file.Source)" "Red"
        Write-ColorOutput "  (Skipping)" "Gray"
        $notFound++
    }
    Write-Host ""
}

# Summary
Write-ColorOutput "[SUMMARY]" "Cyan"
Write-ColorOutput "=" * 70 "Gray"
Write-ColorOutput "Found: $found files" "Green"
Write-ColorOutput "Not Found: $notFound files" "Yellow"

if (!$WhatIf) {
    Write-ColorOutput "Moved: $moved files" "Green"
    Write-Host ""
    Write-ColorOutput "✓ Migration complete!" "Green"
    Write-ColorOutput "Original files kept on Desktop as backup" "Yellow"
} else {
    Write-ColorOutput "`n[WHAT-IF MODE]" "Yellow"
    Write-ColorOutput "No files were actually moved" "Gray"
    Write-ColorOutput "Run without -WhatIf to perform actual migration" "Gray"
}

Write-Host ""
Write-ColorOutput "Next steps:" "Cyan"
Write-ColorOutput "1. Open F:\index.html in browser" "White"
Write-ColorOutput "2. Verify all dashboards work" "White"
Write-ColorOutput "3. Delete Desktop copies after verification" "White"
Write-ColorOutput "4. Bookmark F:\index.html for quick access" "White"
Write-Host ""

# Ask to open F:\
$open = Read-Host "Open F:\ drive in Explorer? (Y/N)"
if ($open -eq 'Y') {
    explorer $DestDrive
}

# Ask to open index.html
if (Test-Path "$DestDrive\index.html") {
    $openIndex = Read-Host "Open F:\index.html in browser? (Y/N)"
    if ($openIndex -eq 'Y') {
        start "$DestDrive\index.html"
    }
}
