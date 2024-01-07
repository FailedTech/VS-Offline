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

Function Get-VSLocation {
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Folder')]
        [switch]$VSFolder,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Catalog')]
        [switch]$VSCatalog
    )
    
    $result = [PSCustomObject]@{
        IsValid = $false
        Val     = ""
    }

    switch -Regex ($PSCmdlet.ParameterSetName) {
        'Folder' {
            $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderBrowser.ShowNewFolderButton = $true
            $folderBrowser.SelectedPath = [string]$(Get-Location)

            try {
                $result.IsValid = ($folderBrowser.ShowDialog() -eq 'OK')
                $result.Val = $result.IsValid ? $folderBrowser.SelectedPath : $(throw "Folder selection canceled.")
            }
            catch {
                Write-Host $_
            }
            
        }

        'Catalog' {
            $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $fileBrowser.Title = "Select Visual Studio Catalog File"
            $fileBrowser.Filter = "Catalog File (*.json)|*.json|All Files (*.*)|*.*"

            try {
                $result.IsValid = ($fileBrowser.ShowDialog() -eq 'OK')
                $result.Val = $result.IsValid `
                    ? (Test-Json $fileBrowser.SelectedPath `
                        ? $fileBrowser.SelectedPath `
                        : $(throw "Invalid JSON file.")) `
                    : $(throw "File selection canceled.")
            }
            catch {
                Write-Host $_
            }
        }

        default {
            Write-Host "Please specify either -VSFolder or -VSCatalog."
        }
    }
    return $result
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