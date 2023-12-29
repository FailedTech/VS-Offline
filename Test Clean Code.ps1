
Add-Type -AssemblyName System.Windows.Forms

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


$jsonString = '{"name": "John", "age": 30, "city": "New York"}'
$jsonString | Test-CatalogPath