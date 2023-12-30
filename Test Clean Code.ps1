# Define the menu hashtable with ID, Name, and Result
$menu = @{
    1 = @{ "Name" = "VS Folder Path"; "Result" = "C:\" }
    2 = @{ "Name" = "bla bla bla"; "Result" = "Some result" }
}

# Display the menu
Write-Host "Menu:"
foreach ($menuItem in $menu.GetEnumerator()) {
    $id = $menuItem.Key
    $name = $menuItem.Value["Name"]
    Write-Host "$id. $name"
}

# Get user input for menu selection
$userChoice = Read-Host "Enter the ID of the menu item you want:"

# Check if the user choice exists in the menu hashtable
if ($menu.ContainsKey([int]$userChoice)) {
    $result = $menu[[int]$userChoice]["Result"]
    Write-Host "Result: $result"
} else {
    Write-Host "Invalid menu choice."
}

