# Define paths for logs
$logPath = "C:\InstallLogs"
$logFile = "$logPath\RuntimeInstall.log"

# Ensure log directory exists
if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath | Out-Null
}

function Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
    Write-Output $message
}

Log "Checking for Microsoft Visual C++ and DirectX Runtimes..."

# Function to check if a program is installed
function IsInstalled {
    param ([string]$programName)
    $installed = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%$programName%'" -ErrorAction SilentlyContinue
    return $installed -ne $null
}

# URLs for downloads
$vc_redist_x64 = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vc_redist_x86 = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
$directx_installer = "https://download.microsoft.com/download/8/4/a/84a35bf1-dafe-4ae8-82af-ad2ae20b6b14/directx_Jun2010_redist.exe"

# Paths to temporary download files
$tempDir = "C:\Temp\RuntimeDownloads"
$tempVC_x64 = "$tempDir\vc_redist.x64.exe"
$tempVC_x86 = "$tempDir\vc_redist.x86.exe"
$tempDirectX = "$tempDir\directx_Jun2010_redist.exe"

# Ensure Temp Directory Exists
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Check for Visual C++ 2022 Redistributable (x64 and x86)
$vcInstalled_x64 = IsInstalled "Microsoft Visual C++ 2022 X64 Minimum Runtime"
$vcInstalled_x86 = IsInstalled "Microsoft Visual C++ 2022 X86 Minimum Runtime"

# Install Visual C++ Redistributables if missing
if (!$vcInstalled_x64) {
    Log "Microsoft Visual C++ 2022 Redistributable (x64) not found. Installing..."
    Invoke-WebRequest -Uri $vc_redist_x64 -OutFile $tempVC_x64
    Start-Process -FilePath $tempVC_x64 -ArgumentList "/quiet /norestart" -Wait
    Log "Installed Microsoft Visual C++ 2022 (x64)"
} else {
    Log "Microsoft Visual C++ 2022 Redistributable (x64) is already installed. Skipping..."
}

if (!$vcInstalled_x86) {
    Log "Microsoft Visual C++ 2022 Redistributable (x86) not found. Installing..."
    Invoke-WebRequest -Uri $vc_redist_x86 -OutFile $tempVC_x86
    Start-Process -FilePath $tempVC_x86 -ArgumentList "/quiet /norestart" -Wait
    Log "Installed Microsoft Visual C++ 2022 (x86)"
} else {
    Log "Microsoft Visual C++ 2022 Redistributable (x86) is already installed. Skipping..."
}

# Check for DirectX installation
$directXKey = "HKLM:\SOFTWARE\Microsoft\DirectX"
$directXInstalled = (Get-ItemProperty -Path $directXKey -Name "Version" -ErrorAction SilentlyContinue) -ne $null

if (!$directXInstalled) {
    Log "DirectX not found. Installing..."
    Invoke-WebRequest -Uri $directx_installer -OutFile $tempDirectX
    Start-Process -FilePath $tempDirectX -ArgumentList "/Q" -Wait
    Log "Installed DirectX"
} else {
    Log "DirectX is already installed. Skipping..."
}

Log "Runtime installation check completed."