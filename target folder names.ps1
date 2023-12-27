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
    $folderNames = Get-ChildItem -Path $targetFolder -Directory | Select-Object -ExpandProperty Name

    # Display the folder names
    Write-Host "Folder names in ${targetFolder}:"
    $folderNames
} else {
    Write-Host "Folder selection canceled."
}
