Add-Type -AssemblyName System.Windows.Forms

$menuArray = @(
    @{ '#' = 1; 'Items' = 'VS Folder Path'; 'Status' = 'N/A' }
    @{ '#' = 2; 'Items' = 'VS Catalog Path'; 'Status' = 'N/A' }
    @{ '#' = 3; 'Items' = 'IDM Path'; 'Status' = 'N/A' }
    @{ '#' = 4; 'Items' = 'Downloads List'; 'Status' = 'N/A' }
    @{ '#' = 5; 'Items' = 'Downloads To IDM'; 'Status' = 'N/A' }
    @{ '#' = 6; 'Items' = 'Clean Up'; 'Status' = 'N/A' }
)
$menuTable = $menuArray | ForEach-Object { [PSCustomObject]$_ }
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
        Error   = ""
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
                    ? ((Test-Json -Path $fileBrowser.SelectedPath) `
                        ? $fileBrowser.SelectedPath `
                        : $(throw "Invalid JSON file.")) `
                    : $(throw "File selection canceled.")
            }
            catch {
                $result.Error = $_
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
    $result = [PSCustomObject]@{
        IsValid = $false
        Val     = ""
    }
    try {
        $jsonContent = Get-Content -Path ($catalogPath) -Raw | ConvertFrom-Json
        $result.IsValid = $jsonContent.PSObject.Properties.Name -contains 'packages'
        $result.IsValid ? ($result.Val = $jsonContent) : (throw "Catalog contains no packages")
    }
    catch {
        Write-Host $_
    }
    return $result
}

Function Show-Menu {
    $menuTable | Sort-Object '#' | Select-Object '#', 'Items', 'Status' | Format-Table -AutoSize
}

Function Update-Option1 {
    $vsFolder = Get-VSLocation -VSFolder
    $vsFolder.IsValid ? ($menuTable[0].Status = $vsFolder.Val ) : $null 
}

Function Update-Option2 {               
    $vsCatalog = Get-VSLocation -VSCatalog
    Write-Host $vsCatalog
    $vsCatalog.IsValid ? ($menuTable[1].Status = $vsCatalog.Val ) : $null
}
#Menu Items                        result
#1 vs folder path                  C:\asd
#2 vs catalog path                 C:\dasds or not a json file err
# clean old items                  checked %
#3 chk IDM path                    C:\
#4 transfer downloads to IDM          0 %

Function Get-Menu {
    while ($true) {
        Show-Menu
        $userInput = read-host [Enter Selection]
        Switch ($userInput) {
            "1" { Update-Option1 ; break }
            "2" { Update-Option2 ; break }
            "3" { Update-Option3 ; break }
            "4" { Update-Option4 ; break }
            "5" { return }
            default { "Please Enter a valid number" }
        }
    }
}

Get-Menu

Pause