
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