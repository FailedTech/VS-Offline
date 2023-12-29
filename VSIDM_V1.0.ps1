Add-Type -AssemblyName System.Windows.Forms

Function Get-FolderLocation {
    param (
        [string]$initialPath = (Get-Location)
    )

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select Visual Studio Offline Folder"
    $folderBrowser.ShowNewFolderButton = $true
    $folderBrowser.SelectedPath = $initialPath
    try {
        return ($folderBrowser.ShowDialog() -eq 'OK') ? $folderBrowser.SelectedPath : $(throw "Folder selection canceled.")
    } catch {
        Write-Host $_
        return $null
    }
}

Function Test-CatalogPath {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$folderPath
    )
    try {
        ($null -eq $folderPath) ? $(throw "Invalid or empty folder path.") : $null
        $catalogPath = Join-Path $folderPath "Catalog.json"
        return (Test-Path $catalogPath -PathType Leaf) ? $catalogPath : $(throw "Catalog.json not found.")
    } catch {
        Write-Host $_
        return $null
    }
}

Function Get-CatalogContent {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$catalogPath
    )
    # Convert JSON content to PowerShell object
    return (Get-Content -Path ($catalogPath) -Raw | ConvertFrom-Json)
}



$getFolderLocation = Get-FolderLocation
$null -ne $getFolderLocation`
    ?(($getFolderLocation | Test-CatalogPath)`
        ?($getFolderLocation | Test-CatalogPath | Get-CatalogContent)`
        :(Write-Host "Catalog.json not found") )`
    :(Write-Host "Folder selection canceled.")
Pause