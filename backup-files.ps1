# Task: Create a PowerShell Script to Backup Files
# Objective:
# Write a PowerShell script that backs up specified files from a source directory to a destination directory. 
# The script should include options for logging and error handling.

# Requirements:
# Parameters:

# Usage: ./backup-files.ps1 -ReadLocation "[C:\Path\to\your\readfile]" 
# >> -WrteLocation "[C:\Path\to\your\writefile]" -FileType "[.txt]" -LogFile "[C:\Path\to\your\logfile]"

# The script should accept the following parameters:
# -Source: The directory from which files will be backed up.
# -Destination: The directory where files will be copied.
# -LogFile: (Optional) A path to a log file to record backup operations.
param (
    [Parameter(Mandatory=$true)]
    [string]$ReadLocation,

    [Parameter(Mandatory=$true)]
    [string]$WriteLocation,

    [string]$FileType = $null,

    [string]$LogFile = $null
)

# Functionality:

# Check if the source directory exists. If not, display an error message and exit the script.
# Test the directory path 
if (-not (Test-Path -Path $ReadLocation)) {
    # Exit if we can't find the path
    Write-Host "
    Can't find the directory $ReadLocation, please ensure it exists at the expected location.
    ";
    exit;
}

Write-Host "
$ReadLocation directory found successfully
";

# Takes in input string, returns boolean based on input string matching yes/no options
function Get-UserConfirmation ($inputString) {
    # Loop for validating y/n inputs
    while ($true) {

        # Get option from users
        $inputString = Read-Host "Couldn't find output directory. Create new directory $WriteLocation in current folder? (y/n)"

        # Handle for yes
        if ($inputString -match '^y|yes|Y|Yes|YES') {
            return $true 
        } elseif ($inputString -match 'n|no|No|NO|N') {
            return $false
        } else {
            Write-Host "Invalid input. Please enter 'y' or 'n'."
        }
    }
}

# Check if the destination directory exists. If it doesn’t, create it.
if (-not (Test-Path -Path $WriteLocation)) {
    Write-Host "Routing"
    # If we should create a new directory
    if (Get-UserConfirmation) {
        # Create the new directory
        New-Item -Path ".\$WriteLocation"
    } else {
        # Exit otherwise
        Write-Host "No directory to write to, exiting...
        ";
        exit;
    }
}

# Copy all files from the source directory to the destination directory.
# If a file already exists in the destination, overwrite it.
if ($FileType) {
    Copy-Item "$ReadLocation\*$FileType" -Destination $WriteLocation
} else {
    Copy-Item "$ReadLocation\*" -Destination $WriteLocation
}

# Log each operation (file copied and any errors) to the log file if the -LogFile parameter is provided.
# Error Handling:

# Use Try, Catch, and Finally blocks to handle any errors that may occur during the copying process.
# Write error messages to the console and to the log file if applicable.
# Output:

# Display a summary message indicating how many files were successfully copied and any errors encountered.