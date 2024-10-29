# Gets graph username and other ID info from the Graph CLI
# Requires organizational permissions
Connect-MgGraph -NoWelcome;

# $organizationalID = Read-Host -Prompt "
# Please enter email";

# Try {
#     Get-MgUser -UserId
# } Catch {
#     Write-Host "Something went wrong";
#     # Disconnect-MgGraph;
# };

Disconnect-MgGraph;
# Usage:
# PWSH: 
# ./get-mygraph-profile.ps1