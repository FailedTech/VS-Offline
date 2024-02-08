Add-Type -AssemblyName System.Windows.Forms


$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$fileBrowser.Title = "Select Visual Studio Catalog File"
$fileBrowser.Filter = "Catalog File (*.json)|*.json|All Files (*.*)|*.*"

if ($fileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Host 'working'
    Write-Host $fileBrowser.FileName
}