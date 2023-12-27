TAdd-Type -AssemblyName System.Windows.Forms

# Create FolderBrowserDialog
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Select Visual Studio Offline Folder"
$folderBrowser.ShowNewFolderButton = $true
$folderBrowser.SelectedPath = Get-Location

# Definitions
$foldersTable = @()
$packagesTable = @()
$diffTable = @()
$idRegex = '(.+?)(?:,|$)'
$versionRegex = 'version=(.+?)(?:,|$)'
$chipRegex = 'chip=(.+?)(?:,|$)'
$languageRegex = 'language=(.+?)(?:,|$)'

