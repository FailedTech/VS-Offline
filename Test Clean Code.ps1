Add-Type -AssemblyName System.Windows.Forms

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
                    ? (Test-Json -Path $fileBrowser.SelectedPath `
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


# Example usage with VSFolder
$a = Get-VSLocation -VSFolder

# Example usage with VSCatalog
$b = Get-VSLocation -VSCatalog

if ( $a.IsValid = $false) {
    Write-Host "if returned $a"
} 
if ($b.IsValid = $false) {
    Write-Host "if returned $a"
}