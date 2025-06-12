# --- PowerShell Script Setup ---
# $ErrorActionPreference = "Stop": Immediately stops script execution when a non-terminating error is encountered.
# $ProgressPreference = "SilentlyContinue": Suppresses progress bar display for Cmdlets like Invoke-WebRequest.
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Trap block to catch any fatal errors and exit with an error code.
trap {
    Write-Host -ForegroundColor Red "Fatal Error: $($_.Exception.Message)"
    exit 1
}

# --- Color Definition Functions (for PowerShell) ---
# These functions use the Write-Host Cmdlet with the -ForegroundColor parameter to output colored text.
# Note: These colors are well-supported in modern Windows Terminal and PowerShell 7+, but may not display correctly in older consoles.
Function Write-Host-Green { param([string]$Message) Write-Host -ForegroundColor Green $Message }
Function Write-Host-Blue { param([string]$Message) Write-Host -ForegroundColor Blue $Message }
Function Write-Host-Yellow { param([string]$Message) Write-Host -ForegroundColor Yellow $Message }
Function Write-Host-Red { param([string]$Message) Write-Host -ForegroundColor Red $Message }
Function Write-Host-Purple { param([string]$Message) Write-Host -ForegroundColor DarkMagenta $Message } # DarkMagenta is typically used for purple in PowerShell
Function Write-Host-Cyan { param([string]$Message) Write-Host -ForegroundColor Cyan $Message }

# --- Configuration Section ---
$LADEFREE_REPO_URL_BASE = "https://github.com/byJoey/ladefree" # Base URL for the Ladefree application GitHub repository
$LADEFREE_REPO_BRANCH = "main" # Branch of the Ladefree repository
$LADE_CLI_NAME = "lade.exe" # Lade CLI executable file name (typically .exe on Windows)
# $env:ProgramFiles is the standard Program Files directory on Windows, e.g., C:\Program Files
$LADE_INSTALL_PATH = "$env:ProgramFiles\LadeCLI" # Standard installation path for Lade CLI

# --- Author Information ---
# Author: Joey
# Blog: joeyblog.net
# Telegram Group: https://t.me/+ft-zI76oovgwNmRh
# Deployed code (note.js) from https://github.com/eooce by Old Wang

# --- Helper Function: Display Welcome Message ---
Function Display-Welcome {
    Clear-Host # Clears the console screen
    Write-Host-Cyan "#############################################################"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#        " -NoNewline; Write-Host-Blue "Welcome to Lade CLI Multi-function Management Script v1.0.0" -NoNewline; Write-Host-Cyan "        #"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#############################################################"
    Write-Host-Green ""
    Write-Host "  >> Author: MrHtunNaung"
    Write-Host "  >> Deployed code (note.js) from https://github.com/eooce by Old Wang "
    Write-Host ""
    Write-Host-Yellow "This is an automated Lade application deployment and management tool designed to simplify operations."
    Write-Host ""
    Read-Host "Press Enter to start..." | Out-Null # Waits for the user to press Enter and discards the input
}

# --- Helper Function: Display Section Header ---
Function Display-SectionHeader {
    param([string]$Title) # Accepts a string parameter as the title
    Write-Host ""
    Write-Host-Purple "--- $Title ---"
    Write-Host-Purple "-----------------------------------"
}

# --- Helper Function: Check if a command exists ---
Function Test-CommandExists {
    param([string]$Command) # Accepts a string parameter as the command name
    # Get-Command tries to find the specified command. -ErrorAction SilentlyContinue suppresses error messages.
    # If the command is found, it returns an object; otherwise, it returns $null.
    (Get-Command -Name $Command -ErrorAction SilentlyContinue) -ne $null
}

# --- Helper Function: Check if Lade CLI exists and is available ---
Function Test-LadeCli {
    Test-CommandExists $LADE_CLI_NAME # Calls Test-CommandExists to check for Lade CLI
}

# --- Helper Function: Ensure Lade is logged in ---
Function Ensure-LadeLogin {
    Write-Host ""
    Write-Host-Purple "--- Checking Lade Login Status ---"
    # Attempts to execute a Lade command that requires authentication (e.g., `lade apps list`).
    # If the command fails (throws an error), it means not logged in or the session has expired.
    try {
        # Use the & operator to execute external executables. Out-Null discards the command's standard output.
        & lade apps list | Out-Null
        Write-Host-Green "Lade is already logged in."
    } catch {
        Write-Host-Yellow "Lade login session expired or not logged in. Please enter your Lade login credentials as prompted."
        try {
            & lade login # Prompts the user to log in
            Write-Host-Green "Lade login successful!"
        } catch {
            Write-Host-Red "Error: Lade login failed. Please check your username/password or network connection."
            exit 1 # Login failed, exit the script
        }
    }
}

# --- Functional Function: Deploy Application ---
Function Deploy-App {
    Display-SectionHeader "Deploy Lade App"

    Ensure-LadeLogin # Ensures the user is logged in

    $LADE_APP_NAME = Read-Host "Please enter the name of the Lade app to deploy (e.g., my-ladefree-app):"
    # [string]::IsNullOrWhiteSpace checks if the string is null, empty, or contains only whitespace characters
    if ([string]::IsNullOrWhiteSpace($LADE_APP_NAME)) {
        Write-Host-Yellow "App name cannot be empty. Cancelling deployment."
        return # Return from the function, do not proceed with deployment
    }

    Write-Host "Checking if app '$LADE_APP_NAME' exists..."
    $app_exists = $false
    try {
        $appList = & lade apps list # Get the list of apps
        # The -like operator is used for wildcard matching. Checks if the app name is included in the list.
        if ($appList -like "*$LADE_APP_NAME*") {
            $app_exists = $true
        }
    } catch {
        # If getting the app list fails, it might be a network issue or Lade CLI issue, but we still try to continue.
        Write-Host-Yellow "Could not retrieve app list to verify existence, assuming non-existent or continuing with create/deploy."
    }

    if ($app_exists) {
        Write-Host-Green "App '$LADE_APP_NAME' already exists, proceeding with deployment update."
    } else {
        Write-Host-Yellow "App '$LADE_APP_NAME' does not exist, attempting to create a new app."
        Write-Host-Cyan "Note: Creating the app will interactively ask for 'Plan' and 'Region', please select manually."
        try {
            & lade apps create "$LADE_APP_NAME" # Try to create the app
            Write-Host-Green "Lade app creation command sent."
        } catch {
            Write-Host-Red "Error: Lade app creation failed. Please check your input or if the app name is available."
            return # Creation failed, return from the function
        }
    }

    Write-Host ""
    Write-Host-Blue "--- Downloading ZIP and Deploying Ladefree App (Git independent) ---"
    # Join-Path Cmdlet securely concatenates paths, handling different path separators.
    $ladefree_temp_download_dir = Join-Path $env:TEMP "ladefree_repo_download_$(Get-Random)"
    # New-Item -ItemType Directory -Force creates a directory and does not throw an error if it already exists. Out-Null suppresses output.
    New-Item -ItemType Directory -Force -Path $ladefree_temp_download_dir | Out-Null

    $ladefree_download_url = "$LADEFREE_REPO_URL_BASE/archive/refs/heads/$LADEFREE_REPO_BRANCH.zip"
    $temp_ladefree_archive = Join-Path $ladefree_temp_download_dir "ladefree.zip"

    Write-Host "Downloading from $LADEFREE_REPO_URL_BASE (Branch: $LADEFREE_REPO_BRANCH) as ZIP package..."
    Write-Host "Download URL: $ladefree_download_url"

    try {
        # Invoke-WebRequest is the primary Cmdlet in PowerShell for downloading files and web content.
        Invoke-WebRequest -Uri $ladefree_download_url -OutFile $temp_ladefree_archive
    } catch {
        Write-Host-Red "Error: Failed to download Ladefree repository ZIP package. Please check the URL or network connection."
        # Remove-Item -Recurse -Force forcefully deletes the directory and its contents, -ErrorAction SilentlyContinue suppresses deletion errors.
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # Download failed, return from the function
    }

    Write-Host "Download complete, extracting..."
    try {
        # Expand-Archive is the PowerShell Cmdlet for extracting ZIP files.
        Expand-Archive -Path $temp_ladefree_archive -DestinationPath $ladefree_temp_download_dir -Force
    } catch {
        Write-Host-Red "Error: Failed to extract Ladefree ZIP package. Please ensure 'Expand-Archive' is available (PowerShell 5.0+ built-in)."
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # Extraction failed, return from the function
    }

    # Find the extracted application directory (e.g., ladefree-main).
    # Get-ChildItem -Directory only gets directories, -Filter "ladefree-*" filters by name.
    # Select-Object -ExpandProperty FullName selects only the full path.
    # Select-Object -First 1 ensures only the first match is taken.
    $extracted_app_path = Get-ChildItem -Path $ladefree_temp_download_dir -Directory -Filter "ladefree-*" | Select-Object -ExpandProperty FullName | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($extracted_app_path)) {
        Write-Host-Red "Error: Could not find the extracted Ladefree application directory in the temporary download directory."
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # Directory not found, return from the function
    }

    Write-Host-Blue "Deploying from local extracted path $extracted_app_path to Lade: $LADE_APP_NAME ..."
    Push-Location $extracted_app_path # Change current working directory to the extracted path
    try {
        & lade deploy --app "$LADE_APP_NAME" # Execute the deployment command
        $deploy_status = $LASTEXITCODE # Get the exit code of the external command
    } catch {
        Write-Host-Red "Error: Lade app deployment failed. Please check for issues with the Ladefree code itself or Lade platform logs."
        Pop-Location # Restore to the previous directory
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # Deployment failed, return from the function
    }
    Pop-Location # Restore to the previous directory

    Write-Host "Cleaning up temporary download directory $ladefree_temp_download_dir..."
    Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue

    if ($deploy_status -ne 0) {
        Write-Host-Red "Error: Lade app deployment failed. Please check for issues with the Ladefree code or Lade platform logs."
        return # Deployment failed, return from the function
    }
    Write-Host-Green "Lade app deployed successfully!"

    Write-Host ""
    Write-Host-Cyan "--- Deployment Complete ---"
}

# --- Functional Function: View All Apps ---
Function View-Apps {
    Display-SectionHeader "View All Lade Apps"

    Ensure-LadeLogin # Ensures the user is logged in

    try {
        & lade apps list # Execute command to view app list
    } catch {
        Write-Host-Red "Error: Could not retrieve app list. Please check network or Lade CLI status."
    }
}

# --- Functional Function: Delete App ---
Function Delete-App {
    Display-SectionHeader "Delete Lade App"

    Ensure-LadeLogin # Ensures the user is logged in

    $APP_TO_DELETE = Read-Host "Please enter the name of the Lade app to delete:"
    if ([string]::IsNullOrWhiteSpace($APP_TO_DELETE)) {
        Write-Host-Yellow "App name cannot be empty. Cancelling deletion."
        return
    }

    Write-Host-Red "Warning: You are about to delete app '$APP_TO_DELETE'. This operation is irreversible!"
    $CONFIRM_DELETE = Read-Host "Are you sure you want to delete? (y/N):"
    $CONFIRM_DELETE = $CONFIRM_DELETE.ToLower() # Convert input to lowercase

    if ($CONFIRM_DELETE -eq "y") {
        try {
            & lade apps remove "$APP_TO_DELETE" # Changed 'delete' to 'remove' as per common CLI practices
            Write-Host-Green "App '$APP_TO_DELETE' successfully deleted."
        } catch {
            Write-Host-Red "Error: Failed to delete app '$APP_TO_DELETE'. Please check if the app name is correct or if you have permissions."
        }
    } else {
        Write-Host-Yellow "Deletion operation cancelled."
    }
}

# --- Functional Function: View App Logs ---
Function View-AppLogs {
    Display-SectionHeader "View Lade App Logs"

    Ensure-LadeLogin # Ensures the user is logged in

    $APP_FOR_LOGS = Read-Host "Please enter the name of the Lade app to view logs for:"
    if ([string]::IsNullOrWhiteSpace($APP_FOR_LOGS)) {
        Write-Host-Yellow "App name cannot be empty. Cancelling log viewing."
        return
    }

    Write-Host-Cyan "Viewing real-time logs for app '$APP_FOR_LOGS' (Press Ctrl+C to stop)..."
    try {
        # The -f flag for lade logs usually means "follow" log output
        & lade logs -a "$APP_FOR_LOGS" -f
    } catch {
        Write-Host-Red "Error: Could not retrieve logs for app '$APP_FOR_LOGS'. Please check if the app name is correct or if the app is running."
    }
}

# --- Initialization Step (Ensuring Lade CLI is installed) ---
Function Install-LadeCli {
    Display-SectionHeader "Check or Install Lade CLI"

    if (Test-LadeCli) {
        Write-Host-Green "Lade CLI is already installed: $(Get-Command $LADE_CLI_NAME).Path"
        return $true # Lade CLI already exists, return true
    }

    Write-Host-Yellow "Lade CLI is not installed. Attempting to automatically install Lade CLI..."

    $lade_release_url = "https://github.com/lade-io/lade/releases"
    $lade_temp_dir = Join-Path $env:TEMP "lade_cli_download_temp_$(Get-Random)"
    New-Item -ItemType Directory -Force -Path $lade_temp_dir | Out-Null

    $os_type = "windows" # Hardcoded as "windows" on Windows
    # Get-WmiObject Win32_Processor retrieves processor information, Architecture property indicates architecture type.
    $arch_type = (Get-WmiObject Win32_Processor).Architecture

    $arch_suffix = ""
    # Set download filename suffix based on processor architecture
    switch ($arch_type) {
        0 { $arch_suffix = "-amd64" } # x86 architecture
        9 { $arch_suffix = "-amd64" } # x64 architecture
        6 { $arch_suffix = "-arm64" } # ARM64 architecture
        default {
            Write-Host-Red "Error: Unsupported Windows architecture: $arch_type"
            Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
            exit 1
        }
    }
    Write-Host-Blue "Detected Windows ($((Get-WmiObject Win32_Processor).Caption)) architecture."

    # Check for necessary tools: Invoke-WebRequest (PowerShell built-in) or curl.exe (if user installed)
    if (-not (Test-CommandExists "curl.exe") -and -not (Test-CommandExists "Invoke-WebRequest")) {
        Write-Host-Red "Error: Neither 'curl.exe' nor 'Invoke-WebRequest' (PowerShell's web client) found. Please ensure PowerShell is updated or curl is installed."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
    # Check for Expand-Archive (PowerShell built-in)
    if (-not (Test-CommandExists "Expand-Archive")) {
        Write-Host-Red "Error: 'Expand-Archive' (PowerShell's decompression command) not found. Please ensure PowerShell 5.0+ is installed."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Host "Fetching the latest version of Lade CLI..."
    try {
        # Invoke-RestMethod is used to invoke RESTful Web services, getting JSON responses from GitHub API.
        $latest_release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/lade-io/lade/releases/latest"
        $latest_release_tag = $latest_release_info.tag_name # Extract tag_name from JSON response
    } catch {
        Write-Host-Red "Error: Could not retrieve the latest version of Lade CLI. Please check network or GitHub API limits."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($latest_release_tag)) {
        Write-Host-Red "Error: Could not determine the latest Lade CLI version."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
    $lade_version = $latest_release_tag
    Write-Host-Green "Latest version detected: $lade_version"

    $filename_to_download = "lade-${os_type}${arch_suffix}.zip" # Lade CLI for Windows is usually a .zip
    $download_url = "$lade_release_url/download/$lade_version/$filename_to_download"
    $temp_archive = Join-Path $lade_temp_dir $filename_to_download

    Write-Host "Download URL: $download_url"
    Write-Host "Downloading $filename_to_download to $temp_archive..."
    try {
        Invoke-WebRequest -Uri $download_url -OutFile $temp_archive # Download the file
    } catch {
        Write-Host-Red "Error: Failed to download Lade CLI. Please check network connection or if the URL is correct."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Host "Download complete, extracting..."
    try {
        Expand-Archive -Path $temp_archive -DestinationPath $lade_temp_dir -Force # Extract the ZIP file
    } catch {
        Write-Host-Red "Error: Failed to extract ZIP file. Please ensure 'Expand-Archive' Cmdlet is available (PowerShell 5.0+)."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Find the Lade CLI executable in the extracted directory.
    # -Recurse recursively searches subdirectories, -File only finds files, -Filter filters by filename.
    $extracted_lade_path = Get-ChildItem -Path $lade_temp_dir -Recurse -File -Filter $LADE_CLI_NAME | Select-Object -ExpandProperty FullName | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($extracted_lade_path)) {
        Write-Host-Red "Error: Could not find '$LADE_CLI_NAME' executable in the extracted temporary directory. Please check the archive content."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Ensure the target installation path exists
    if (-not (Test-Path $LADE_INSTALL_PATH)) {
        New-Item -ItemType Directory -Force -Path $LADE_INSTALL_PATH | Out-Null
    }

    Write-Host "Moving Lade CLI to $LADE_INSTALL_PATH..."
    try {
        # Move-Item moves files. -Force forcefully overwrites the target (if it exists).
        Move-Item -Path $extracted_lade_path -Destination (Join-Path $LADE_INSTALL_PATH $LADE_CLI_NAME) -Force
    } catch {
        Write-Host-Red "Error: Failed to move Lade CLI file. Administrator permissions may be required or directory does not exist."
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Add Lade CLI to the system PATH environment variable (if not already added)
    # This usually requires administrator permissions to modify machine-level environment variables.
    try {
        # [Environment]::GetEnvironmentVariable gets environment variables.
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        # Check if the installation path is already included in PATH.
        if (-not ($currentPath -split ';' -contains $LADE_INSTALL_PATH)) {
            Write-Host-Yellow "Adding '$LADE_INSTALL_PATH' to system PATH. This requires administrator permissions."
            $newPath = "$currentPath;$LADE_INSTALL_PATH"
            # [Environment]::SetEnvironmentVariable sets environment variables.
            [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
            Write-Host-Green "Lade CLI installation path added to system PATH. You may need to restart your PowerShell session for it to take effect."
        }
    } catch {
        Write-Host-Yellow "Warning: Could not add Lade CLI path to system PATH environment variable. Please manually add '$LADE_INSTALL_PATH' to your PATH to run 'lade' commands from any location."
    }

    Write-Host-Green "Lade CLI successfully downloaded, extracted, and installed to $LADE_INSTALL_PATH"
    Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
    return $true # Lade CLI installed successfully
}


# --- Main Execution Flow ---

# Display welcome page
Display-Welcome

# 2. Ensure Lade CLI is installed
# If Install-LadeCli returns false (installation failed), exit the script.
if (-not (Install-LadeCli)) {
    Write-Host-Red "Error: Lade CLI installation failed. Script will exit."
    exit 1
}

# --- Main Menu ---
while ($true) { # Infinite loop until the user chooses to exit
    Write-Host ""
    Write-Host-Cyan "#############################################################"
    Write-Host-Cyan "#           " -NoNewline; Write-Host-Blue "Lade Management Main Menu" -NoNewline; Write-Host-Cyan "                         #"
    Write-Host-Cyan "#############################################################"
    Write-Host-Green "1. " -NoNewline; Write-Host "Deploy Ladefree App"
    Write-Host-Green "2. " -NoNewline; Write-Host "View All Lade Apps"
    Write-Host-Green "3. " -NoNewline; Write-Host "Delete Lade App"
    Write-Host-Green "4. " -NoNewline; Write-Host "View App Logs"
    Write-Host-Green "5. " -NoNewline; Write-Host "Refresh Lade Login Status"
    Write-Host-Red "6. " -NoNewline; Write-Host "Exit"
    Write-Host-Cyan "-------------------------------------------------------------"
    $CHOICE = Read-Host "Please select an operation (1-6):"

    switch ($CHOICE) { # Execute corresponding function based on user's choice
        "1" { Deploy-App }
        "2" { View-Apps }
        "3" { Delete-App }
        "4" { View-AppLogs }
        "5" { Ensure-LadeLogin }
        "6" { Write-Host-Cyan "Exiting script. Goodbye!"; break } # Exit loop
        default { Write-Host-Red "Invalid selection, please enter a number between 1 and 6." }
    }
    Write-Host ""
    Read-Host "Press Enter to continue..." | Out-Null # Wait for the user to press Enter to continue
}

Write-Host-Blue "Script execution completed."
