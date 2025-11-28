# First run 'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser' to allow script to run

# Ensure script stops on errors
$ErrorActionPreference = "Stop"

Write-Host "Starting software installation..." -ForegroundColor Cyan

# Function to handle software installation with error checking
function Install-Software {
    param (
        [string[]]$softwareIds  # Accept an array of software IDs
    )

    foreach ($softwareId in $softwareIds) {
        Write-Host "Installing $softwareId..." -ForegroundColor Cyan

        try {
            # Suppress output from the winget command
            $wingetResult = winget install --id $softwareId --source winget --accept-package-agreements --accept-source-agreements *> $null

            if ($?) {
                Write-Host "$softwareId installed successfully!" -ForegroundColor Green
            } else {
                Write-Host "Error installing $softwareId." -ForegroundColor Red
            }
        } catch {
            Write-Host "An error occurred while installing $softwareId: $_" -ForegroundColor Red
        }
    }
}

# --- Install Software ---
Install-Software -softwareIds @(
    "AgileBits.1Password",
    "Mozilla.Firefox",
    "Microsoft.Office.365",
    "Microsoft.Teams",
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "jesseduffield.lazygit",
    "PortSwigger.BurpSuiteProfessional"
)

# --- Configure Firefox to Install Extensions (FoxyProxy and Multi-Account Containers) ---
Write-Host "Configuring Firefox to install FoxyProxy and Multi-Account Containers extensions..."

# Create policy directory if it doesn't exist
$policyDir = "$env:ProgramFiles\Mozilla Firefox\distribution"
if (!(Test-Path $policyDir)) {
    try {
        New-Item -ItemType Directory -Path $policyDir -Force | Out-Null
        Write-Host "Created directory: $policyDir" -ForegroundColor Green
    } catch {
        Write-Host "Error creating directory for Firefox extensions: $_" -ForegroundColor Red
    }
}

# Extension URLs
$policyJson = @"
{
  "policies": {
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi"
      ]
    }
  }
}
"@

# Write the policies.json file
$policyFile = Join-Path $policyDir "policies.json"
try {
    $policyJson | Out-File -FilePath $policyFile -Encoding UTF8
    Write-Host "FoxyProxy and Multi-Account Containers will be installed automatically next time Firefox launches." -ForegroundColor Green
} catch {
    Write-Host "Error writing policies.json file: $_" -ForegroundColor Red
}

Write-Host "All software installed successfully!" -ForegroundColor Green
