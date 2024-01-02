Add-Type -AssemblyName System.Windows.Forms
Function Get-VSLocation {
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Folder')]
        [switch]$VSFolder,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Catalog')]
        [switch]$VSCatalog
    )


    if ($VSFolder) {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.ShowNewFolderButton = $true
        $folderBrowser.SelectedPath = [string]$(Get-Location)

        try {
            return ($folderBrowser.ShowDialog() -eq 'OK') ? $folderBrowser.SelectedPath : $(throw "Folder selection canceled.")
        }
        catch {
            Write-Host $_
            return $false
        }
    }
    elseif ($VSCatalog) {
        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $fileBrowser.Title = "Select Visual Studio Catalog File"
        $fileBrowser.Filter = "Catalog File (*.json)|*.json|All Files (*.*)|*.*"

        try {
            return ($fileBrowser.ShowDialog() -eq 'OK') ? $fileBrowser.FileName : $(throw "File selection canceled.")
        }
        catch {
            Write-Host $_
            return $false
        }
    }
    else {
        Write-Host "Please specify either -VSFolder or -VSCatalog."
        return $false
    }
}

# Example usage with VSFolder
Get-VSLocation -VSFolder

# Example usage with VSCatalog
Get-VSLocation -VSCatalog
