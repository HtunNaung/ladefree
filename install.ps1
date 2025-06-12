# --- PowerShell Script Setup ---
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

trap {
    Write-Host -ForegroundColor Red "Fatal Error: $($_.Exception.Message)"
    exit 1
}

# --- Text Color Functions ---
Function Write-Host-Green { param([string]$Message) Write-Host -ForegroundColor Green $Message }
Function Write-Host-Blue { param([string]$Message) Write-Host -ForegroundColor Blue $Message }
Function Write-Host-Yellow { param([string]$Message) Write-Host -ForegroundColor Yellow $Message }
Function Write-Host-Red { param([string]$Message) Write-Host -ForegroundColor Red $Message }
Function Write-Host-Purple { param([string]$Message) Write-Host -ForegroundColor DarkMagenta $Message }
Function Write-Host-Cyan { param([string]$Message) Write-Host -ForegroundColor Cyan $Message }

# --- Global Variables ---
$LADEFREE_REPO_URL_BASE = "https://github.com/byJoey/ladefree"
$LADEFREE_REPO_BRANCH = "main"
$LADE_CLI_NAME = "lade.exe"
$LADE_INSTALL_PATH = "$env:ProgramFiles\LadeCLI"

# --- Function: Display Welcome Message ---
Function Display-Welcome {
    Clear-Host
    Write-Host-Cyan "#############################################################"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#        " -NoNewline; Write-Host-Blue "Welcome to Lade CLI Auto Deployment Script v1.0.0" -NoNewline; Write-Host-Cyan "        #"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#############################################################"
    Write-Host ""
    Write-Host "  >> Author: MrHtunNaung"
    Write-Host "  >> Related project note.js: https://github.com/eooce"
    Write-Host ""
    Write-Host-Yellow "This is an automatic tool for deploying Lade apps, aiming to simplify deployment operations."
    Write-Host ""
    Read-Host "Press Enter to continue..." | Out-Null
}

Function Display-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host-Purple "--- $Title ---"
    Write-Host-Purple "-----------------------------------"
}

Function Test-CommandExists {
    param([string]$Command)
    (Get-Command -Name $Command -ErrorAction SilentlyContinue) -ne $null
}

Function Test-LadeCli {
    Test-CommandExists $LADE_CLI_NAME
}

Function Ensure-LadeLogin {
    Write-Host ""
    Write-Host-Purple "--- Checking Lade Login Status ---"
    try {
        & lade apps list | Out-Null
        Write-Host-Green "Lade is already logged in."
    } catch {
        Write-Host-Yellow "Login session expired or not logged in. Please enter your credentials."
        try {
            & lade login
            Write-Host-Green "Login successful."
        } catch {
            Write-Host-Red "Error: Failed to log in. Please check your username/password."
            exit 1
        }
    }
}

Function Deploy-App {
    Display-SectionHeader "Deploy Lade App"
    Ensure-LadeLogin

    $LADE_APP_NAME = Read-Host "Enter the name of the Lade app to deploy (e.g., my-ladefree-app):"
    if ([string]::IsNullOrWhiteSpace($LADE_APP_NAME)) {
        Write-Host-Yellow "App name cannot be empty. Cancelling deployment."
        return
    }

    Write-Host "Checking if app '$LADE_APP_NAME' exists..."
    $app_exists = $false
    try {
        $appList = & lade apps list
        if ($appList -like "*$LADE_APP_NAME*") {
            $app_exists = $true
        }
    } catch {
        Write-Host-Yellow "Unable to fetch app list. Please confirm network or Lade CLI issues."
    }

    if ($app_exists) {
        Write-Host-Green "App '$LADE_APP_NAME' already exists. Proceeding with deployment."
    } else {
        Write-Host-Yellow "App '$LADE_APP_NAME' does not exist. Creating new app."
        Write-Host-Cyan "Note: You may need to select 'Plan' and 'Region' during creation."
        try {
            & lade apps create "$LADE_APP_NAME"
            Write-Host-Green "App '$LADE_APP_NAME' created successfully."
        } catch {
            Write-Host-Red "Error: Failed to create Lade app. Please check details and try again."
            return
        }
    }

    Write-Host ""
    Write-Host-Blue "--- Downloading Ladefree App ZIP (Instead of Git clone) ---"
    $ladefree_temp_download_dir = Join-Path $env:TEMP "ladefree_repo_download_$(Get-Random)"
    New-Item -ItemType Directory -Force -Path $ladefree_temp_download_dir | Out-Null

    $ladefree_download_url = "$LADEFREE_REPO_URL_BASE/archive/refs/heads/$LADEFREE_REPO_BRANCH.zip"
    $temp_ladefree_archive = Join-Path $ladefree_temp_download_dir "ladefree.zip"

    Write-Host "Downloading from $LADEFREE_REPO_URL_BASE (Branch: $LADEFREE_REPO_BRANCH)..."

    try {
        Invoke-WebRequest -Uri $ladefree_download_url -OutFile $temp_ladefree_archive
        Write-Host "Download complete. Extracting..."
        Expand-Archive -Path $temp_ladefree_archive -DestinationPath $ladefree_temp_download_dir -Force
    } catch {
        Write-Host-Red "Error: Failed to download or extract Ladefree ZIP. Cleaning up..."
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return
    }

    $extracted_app_path = (Get-ChildItem -Path $ladefree_temp_download_dir -Directory | Where-Object { $_.Name -like "ladefree-*" } | Select-Object -ExpandProperty FullName | Select-Object -First 1)
    if ([string]::IsNullOrWhiteSpace($extracted_app_path)) {
        Write-Host-Red "Error: Cannot find extracted app directory. Cleaning up..."
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return
    }

    Write-Host-Blue "Deploying from $extracted_app_path to Lade App '$LADE_APP_NAME'..."
    Push-Location $extracted_app_path
    try {
        & lade deploy --app "$LADE_APP_NAME"
        $deploy_status = $LASTEXITCODE
    } catch {
        Write-Host-Red "Error: Deployment failed. Check logs on the Lade platform."
        Pop-Location
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return
    }
    Pop-Location

    Write-Host "Cleaning up temporary directory..."
    Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue

    if ($deploy_status -ne 0) {
        Write-Host-Red "Error: Deployment failed. Please review the Lade platform logs."
        return
    }
    Write-Host-Green "Deployment successful!"
    Write-Host ""
    Write-Host-Cyan "--- Deployment Complete ---"
}

# --- Start Execution ---
Display-Welcome
Deploy-App
