# Lavaz Nexus Vault - Automated Build Setup for Windows PowerShell
# This script automates the entire APK build process

param(
    [string]$BuildType = "debug",
    [switch]$Install,
    [switch]$Release
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Success = "Green"
    Error = "Red"
    Info = "Cyan"
    Warning = "Yellow"
}

function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    $Color = $Colors[$Type] ?? "White"
    Write-Host "$(Get-Date -Format 'HH:mm:ss') | $Message" -ForegroundColor $Color
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Header
Write-Host "`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  Lavaz Nexus Vault - Automated APK Build Setup                ║" -ForegroundColor Magenta
Write-Host "║  Windows PowerShell Build Script                              ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Step 1: Check Prerequisites
Write-Status "Step 1: Verifying Prerequisites..." "Info"

$PrereqCheck = $true

if (-not (Test-Command "java")) {
    Write-Status "❌ Java not found. Install JDK 11+: https://www.oracle.com/java/technologies/downloads/" "Error"
    $PrereqCheck = $false
}
else {
    $JavaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    Write-Status "✓ Java installed: $JavaVersion" "Success"
}

if (-not (Test-Command "git")) {
    Write-Status "❌ Git not found. Install from: https://git-scm.com/" "Error"
    $PrereqCheck = $false
}
else {
    Write-Status "✓ Git installed" "Success"
}

if (-not $PrereqCheck) {
    Write-Status "Please install missing prerequisites and try again." "Error"
    exit 1
}

# Step 2: Clean and Clone Repository
Write-Status "Step 2: Setting up repository..." "Info"

$ProjectPath = "$PSScriptRoot\lavaz-nexus-vault"
$RepoUrl = "https://github.com/liquidlavaz-art/lavaz-nexus-vault.git"

if (Test-Path $ProjectPath) {
    Write-Status "Repository folder exists. Cleaning..." "Warning"
    Remove-Item -Path $ProjectPath -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Write-Status "Cloning repository..." "Info"
git clone $RepoUrl $ProjectPath

if ($LASTEXITCODE -ne 0) {
    Write-Status "❌ Failed to clone repository" "Error"
    exit 1
}

Write-Status "✓ Repository cloned successfully" "Success"

# Step 3: Verify Project Structure
Write-Status "Step 3: Verifying project structure..." "Info"

$RequiredFiles = @(
    "build.gradle",
    "settings.gradle",
    "gradlew.bat",
    "app/build.gradle",
    "app/src/main/AndroidManifest.xml"
)

$StructureValid = $true
foreach ($File in $RequiredFiles) {
    $FilePath = Join-Path $ProjectPath $File
    if (Test-Path $FilePath) {
        Write-Status "✓ Found: $File" "Success"
    }
    else {
        Write-Status "❌ Missing: $File" "Error"
        $StructureValid = $false
    }
}

if (-not $StructureValid) {
    Write-Status "Project structure validation failed." "Error"
    exit 1
}

Write-Status "✓ Project structure is valid" "Success"

# Step 4: Build APK
Write-Status "Step 4: Building APK..." "Info"

Set-Location $ProjectPath

$BuildTarget = if ($Release) { "assembleRelease" } else { "assembleDebug" }
$BuildOutput = "app\build\outputs\apk\$($BuildTarget.ToLower().Replace('assemble', ''))\app-$($BuildTarget.ToLower().Replace('assemble', '')).apk"

Write-Status "Build Type: $BuildTarget" "Info"
Write-Status "Building... This may take 3-5 minutes on first run" "Warning"

& .\gradlew.bat $BuildTarget

if ($LASTEXITCODE -ne 0) {
    Write-Status "❌ Build failed" "Error"
    exit 1
}

Write-Status "✓ Build completed successfully" "Success"

# Step 5: Verify APK
Write-Status "Step 5: Verifying APK output..." "Info"

$DebugApk = "app\build\outputs\apk\debug\app-debug.apk"
$ReleaseApk = "app\build\outputs\apk\release\app-release-unsigned.apk"

$ApkPath = if ($Release) { $ReleaseApk } else { $DebugApk }

if (Test-Path $ApkPath) {
    $ApkSize = (Get-Item $ApkPath).Length / 1MB
    Write-Status "✓ APK Generated: $ApkPath" "Success"
    Write-Status "  Size: $([Math]::Round($ApkSize, 2)) MB" "Info"
}
else {
    Write-Status "❌ APK not found at expected location" "Error"
    exit 1
}

# Step 6: Install on Device (Optional)
if ($Install) {
    Write-Status "Step 6: Installing APK on device..." "Info"
    
    if (-not (Test-Command "adb")) {
        Write-Status "❌ ADB not found. Install Android SDK Platform Tools" "Error"
        Write-Status "   Or enable USB debugging and try again" "Warning"
    }
    else {
        $Devices = adb devices | Select-Object -Skip 1 | Where-Object { $_ -and $_ -notmatch "List" }
        
        if ($Devices.Count -eq 0) {
            Write-Status "❌ No devices detected. Connect your Android device via USB" "Error"
        }
        else {
            Write-Status "Installing on device..." "Info"
            adb install -r $ApkPath
            
            if ($LASTEXITCODE -eq 0) {
                Write-Status "✓ APK installed successfully" "Success"
            }
            else {
                Write-Status "❌ Installation failed" "Error"
            }
        }
    }
}

# Final Summary
Write-Host "`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✓ BUILD COMPLETE                                            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Status "APK Location: $ApkPath" "Success"
Write-Status "Project Path: $ProjectPath" "Info"

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. To install on device:"
Write-Host "     adb install -r ""$ApkPath"""
Write-Host ""
Write-Host "  2. To build release APK:"
Write-Host "     PowerShell -ExecutionPolicy Bypass -File $PSCommandPath -Release"
Write-Host ""
Write-Host "  3. To build and install automatically:"
Write-Host "     PowerShell -ExecutionPolicy Bypass -File $PSCommandPath -Install"
Write-Host ""

Write-Status "Build process completed!" "Success"
