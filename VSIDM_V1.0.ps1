Add-Type -AssemblyName System.Windows.Forms

Function Get-VSFolderPath {
    param (
        [string]$initialPath = (Get-Location)
    )
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select Visual Studio Offline Folder"
    $folderBrowser.ShowNewFolderButton = $true
    $folderBrowser.SelectedPath = $initialPath
    try {
        return ($folderBrowser.ShowDialog() -eq 'OK') ? $folderBrowser.SelectedPath : $(throw "Folder selection canceled.")
    }
    catch {
        Write-Host $_
        return $false
    }
}

Function Get-VSCatalogPath {
    param (
        OptionalParameters
    )
    
}

Function Test-VSCatalogPath {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$catalogPath
    )
    try {
        $catalogExists = Test-Path $catalogPath -PathType Leaf
        $isValidFormat = $catalogExists ? $catalogPath -match '\.json$' : $(throw "file path err: $catalogPath")
        return $isValidFormat ? $catalogPath : $(throw "format err: $catalogPath is not a .Json file")
    }
    catch {
        Write-Host $_
        return $false
    }
}

Function Get-CatalogContent {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$catalogPath
    )
    try {
        return (Get-Content -Path ($catalogPath) -Raw | ConvertFrom-Json)
    }
    catch {
        Write-Host $_
        return $false
    }
}


$isValidPath = Test-Path -Path $folderPath -PathType Container
$getFolderLocation = Get-FolderPath
$getCatalogPath = $getFolderLocation ? ($getFolderLocation | Test-CatalogPath) : $false
$getCatalogContent = $getCatalogPath ? ($getCatalogPath | Get-CatalogContent) : $false


#Menu Items                        result
#1 vs folder path                  C:\asd
#2 vs catalog path                 C:\dasds or not a json file err
# clean old items                  checked %
#3 chk IDM path                    C:\
#4 transfer downloads to IDM          0 %

Pause