Add-Type -AssemblyName System.Windows.Forms


$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$fileBrowser.Title = "Select Visual Studio Catalog File"
$fileBrowser.Filter = "Catalog File (*.json)|*.json|All Files (*.*)|*.*"

Write-Host ($fileBrowser.ShowDialog() -eq 'OK')
Write-Host $fileBrowser.SelectedPath
