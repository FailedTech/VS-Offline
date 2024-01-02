Add-Type -AssemblyName System.Windows.Forms

$menuArray = @(
    @{ '#' = 1; 'Items' = 'VS Folder Path'; 'Status' = 'N/A' }
    @{ '#' = 2; 'Items' = 'VS Catalog Path'; 'Status' = 'N/A' }
    @{ '#' = 3; 'Items' = 'Check IDM Path'; 'Status' = 'N/A' }
    @{ '#' = 4; 'Items' = 'View Downloads List'; 'Status' = 'N/A' }
    @{ '#' = 5; 'Items' = 'Add Downloads To IDM'; 'Status' = 'N/A' }
    @{ '#' = 6; 'Items' = 'Clean Up'; 'Status' = 'N/A' }

)
$menuTable = $menuArray | ForEach-Object { [PSCustomObject]$_ }
$menuTable | Sort-Object '#' | Select-Object '#', 'Items', 'Status' | Format-Table -AutoSize

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
$getVSFolderPath = Get-VSFolderPath
$getCatalogPath = $getVSFolderPath ? ($getVSFolderPath | Test-CatalogPath) : $false
$getCatalogContent = $getCatalogPath ? ($getCatalogPath | Get-CatalogContent) : $false


#Menu Items                        result
#1 vs folder path                  C:\asd
#2 vs catalog path                 C:\dasds or not a json file err
# clean old items                  checked %
#3 chk IDM path                    C:\
#4 transfer downloads to IDM          0 %



Pause