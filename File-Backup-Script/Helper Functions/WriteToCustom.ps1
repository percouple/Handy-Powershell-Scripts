

# Logs passed string to the logfile and/or host
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