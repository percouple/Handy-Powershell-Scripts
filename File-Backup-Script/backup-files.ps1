# This script backs up files from one directory to another
# It takes in 5 parameters: the source file path, the write file path,
# whether to set the file up on a schedule (optional), 
# a filter for the type of file to copy (optional), 
# a log file (option)

# Usage: ./backup-files.ps1 -ReadLocation "[C:\Path\to\your\readfile]" 
# >> -WrteLocation "[C:\Path\to\your\writefile]" 
# >> -Schedule ["Daily"]
# >> -FileType "[.txt]" 
# >> -LogFile "[C:\Path\to\your\logfile]"
# >> -Overwrite ["$true"]

# The script should accept the following parameters:
# -Source: The directory from which files will be backed up.
# -Destination: The directory where files will be copied.
# -LogFile: (Optional) A path to a log file to record backup operations.
# -Overwrite: Specifies whether to overwrite files already found in the path. 
param (
    [Parameter(Mandatory=$true)]
    [string]$ReadLocation,

    [Parameter(Mandatory=$true)]
    [string]$WriteLocation,

    [ValidateSet("Hourly", "Daily", "Weekly", "Monthly")]
    [string]$Schedule = $null,

    [ValidateSet(".aac", ".ai", ".avi", ".bmp", ".csv", ".doc", ".docx", 
    ".flac", ".gif", ".gz", ".html", ".htm", ".indd", ".ini", 
    ".json", ".jpg", ".jpeg", ".js", ".mkv", ".mdb", ".mov", 
    ".mp3", ".pdf", ".png", ".ppt", ".pptx", ".pst", ".rar", 
    ".sql", ".tar", ".tiff", ".txt", ".vhd", ".vhdx", ".vmdk", 
    ".zip")]
    [string]$FileType = $null,

    [string]$LogFile = $null,

    [bool]$Overwrite = $false
)

# Takes in input string from (y/n) prompt, returns boolean
# Expected behavior - Get-UserConfirmation("yes") = $true, "no" = $false
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

function Write-ToCustom {
    param (
        [string]$inputString,
        [string]$Destination
    )
    if ($Destination.Contains("Host")) {
        Write-Host $inputString
    }
    if ($LogFile -and $Destination.Contains("LogFile")) {
        Out-File -Path $LogFile -InputObject $inputString -Append
    }
}

# Delete Logfile if it already exists
if (Test-Path -Path $LogFile) {
    Remove-Item $LogFile;
}

# Force Overwrite to $false if not flagged on execute
if (-not ($Overwrite)) {
    $Overwrite = $false;
}

Write-ToCustom -inputString "Task initiated on $(Get-Date) with parameters:
    -ReadLocation: $ReadLocation
    -WriteLocation $WriteLocation
    -Schedule $(if (-not $Schedule) {"none"} else {$Schedule})
    -FileType $(if (-not $FileType) {"none"} else {$FileType})
    -LogFile $(if (-not $LogFile) {"none"} else {$LogFile})
    -Overwrite $OverWrite
    " -Destination "LogFile";

# If source directory doesn't exist
# display an error message and exit the script.
if (-not (Test-Path -Path $ReadLocation)) {
    # Exit if we can't find the path
    Write-ToCustom -inputString "
    Can't find the directory $ReadLocation, please ensure it exists at the expected location.
    " -Destination "Host, LogFile";
    exit;
}

Write-ToCustom -inputString "  Read directory found successfully: $ReadLocation" -Destination "LogFile";

# Check if the destination directory exists. 
# If it doesn’t, create it.
if (-not (Test-Path -Path $WriteLocation)) {
    Write-ToCustom "No location found for write directory $($WriteLocation). 
Prompting user to create directory..." -Destination "LogFile";

    # If we should create a new directory
    if (Get-UserConfirmation) {

        # Create the new directory
        New-Item -Path ".\$WriteLocation"
    } else {
        # Exit otherwise
        Write-ToCustom "User chose to not write to the directory, exiting...
        " -Destination "Host, LogFile";
        exit;
    }
}

Write-ToCustom "  Write directory located successfully: $WriteLocation
" -Destination "LogFile"
Write-ToCustom "I/O located successfully, copying..." -Destination "Host, LogFile";

# Handle copies if given a file type
# Get files of the read directory in a collection 
if ($FileType) {
    Write-ToCustom "
Filetype detected: $FileType. Filter applied" -Destination "LogFile";
    $files = Get-ChildItem -Path "$ReadLocation\*$FileType"
} else {
    Write-ToCustom "
No filetype detected. No filter applied.
    " -Destination "LogFile";
    $files = Get-ChildItem -Path $ReadLocation;
}

# Establish 
$CopiesSuccessful = 0;
$CopiesAborted = 0;

function Get-SpinnerIncrement {
    param (
        [Int32]$CopiesSuccessful
    )
    switch ($CopiesSuccessful % 4) {
        1 { Write-Host -NoNewline "`rCopying."}
        2 { Write-Host -NoNewline "`rCopying.."}
        3 { Write-Host -NoNewline "`rCopying..."}
        0 { Write-Host -NoNewline "`rCopying"}
    }
}

# Copy each file in our collection to the destination folder
foreach ($file in $files) {

    # Check for the file already existing in the write location
    $FileAlreadyExists = Test-Path "$file"
    $ShortFileName = Split-Path -Path $file -Leaf

    # If a file already exists in the write location && Overwrite === false
    if ($FileAlreadyExists -and $Overwrite -eq $false ) {
        Write-ToCustom "File [$ShortFileName] was found inside $WriteLocation. 
        Overwrite parameter is disabled, cancelling backup for this file." -Destination "LogFile";
        # Continue through loop
        continue;
    }

    Try {
        # Execute Copy
        Copy-Item -Path $file -Destination $WriteLocation
        $CopiesSuccessful += 1;
    } Catch {
        Write-ToCustom "Could not copy $ShortFileName" -Destination "LogFile";
        $CopiesAborted += 1;
    }

    Get-SpinnerIncrement -CopiesSuccessful $CopiesSuccessful;
}

Write-Host "`r                     "

Write-ToCustom "
Backup process complete. 
  $CopiesSuccessful files copied successfully. 
  $CopiesAborted files had issues and could not be copied to the backup drive.
" -Destination "Host, LogFile"

# Use Try, Catch, and Finally blocks to handle any errors that may occur during the copying process.
# Write error messages to the console and to the log file if applicable.
# Output:

# Display a summary message indicating how many files were successfully copied and any errors encountered.