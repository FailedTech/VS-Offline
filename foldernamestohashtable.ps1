Add-Type -AssemblyName System.Windows.Forms

# Create FolderBrowserDialog
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Select a target folder"
$folderBrowser.ShowNewFolderButton = $false
$folderBrowser.SelectedPath = Get-Location

# Show the dialog and check if the user clicked OK
if ($folderBrowser.ShowDialog() -eq 'OK') {
    # Get the selected folder path
    $targetFolder = $folderBrowser.SelectedPath

    # Get all folder names inside the selected folder
    $folderNames = @(Get-ChildItem -Path $targetFolder -Directory | Select-Object -ExpandProperty Name)
}
else {
    Write-Host "Folder selection canceled."
}

# Define regular expressions to extract information
$idRegex = '(.+?)(?:,|$)'
$versionRegex = 'version=(.+?)(?:,|$)'
$chipRegex = 'chip=(.+?)(?:,|$)'
$languageRegex = 'language=(.+?)(?:,|$)'

# Create an array to store hashtables
$hashTables = @()

# Process each input string
foreach ($inputString in $folderNames) {
    # Extract information using regular expressions
    $id = if ($inputString -match $idRegex) { $matches[1] } else { $null }
    $version = if ($inputString -match $versionRegex) { $matches[1] } else { $null }
    $chip = if ($inputString -match $chipRegex) { $matches[1] } else { $null }
    $language = if ($inputString -match $languageRegex) { $matches[1] } else { $null }

    # Create hashtable
    $hashTable = @{
        'id'       = $id
        'version'  = $version
        'chip'     = $chip
        'language' = $language
    }

    # Add hashtable to the array
    $hashTables += New-Object PSObject -Property $hashTable
}

# Display the output in a tabular format with specified property order
$hashTables | Select-Object id, version, chip, language | Format-Table -AutoSize
