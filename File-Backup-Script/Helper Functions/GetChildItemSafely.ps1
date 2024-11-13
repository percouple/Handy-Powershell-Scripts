

# Initialize a hash set to track visited directories
$visitedDirectories = @{}
# Track directories as we move through to avoid any loops
function Get-ChildItemSafely {
    param ($path)

    # Check if the directory has been visited
    if ($visitedDirectories.ContainsKey($path)) {
        return @()  # Skip directories we've already visited
    }

    # Mark the directory as visited
    $visitedDirectories[$path] = $true

    
    # Get child items from this directory
    return Get-ChildItem -Path $path -Recurse
    
    # Spinner for gathering files to copy
    Write-ToCustom "Gathering files: $($path)" -Destination "Host, LogFile"
}