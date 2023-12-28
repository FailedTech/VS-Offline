Add-Type -AssemblyName System.Windows.Forms

Function Get-FolderLocation {
    param (
        [string]$initialPath = (Get-Location)
    )

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select Visual Studio Offline Folder"
    $folderBrowser.ShowNewFolderButton = $true
    $folderBrowser.SelectedPath = $initialPath

    $result = [PSCustomObject]@{
        IsValid = $folderBrowser.ShowDialog() -eq 'OK'
        Value   = $folderBrowser.SelectedPath ?? "Folder selection canceled."
    }

    return $result
}

Function Test-CatalogPath {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$folderPath
    )
    return Test-Path (Join-Path $folderPath "Catalog.json") -PathType Leaf
}

Function Get-CatalogContent {
    # Convert JSON content to PowerShell object
    return Get-Content -Path ($catalogPath) -Raw | ConvertFrom-Json
}


"Catalog.json not found"
$a = Get-FolderLocation
$a.Value 
$a.Value | Test-CatalogPath
Pause