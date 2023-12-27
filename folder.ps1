# Read the content of version 1 (Filtered.json)
$jsonContent = Get-Content -Path .\Filtered.json -Raw

# Convert JSON content to PowerShell object
$filteredObject = $jsonContent | ConvertFrom-Json

# Create directories based on the information from version 1
$filteredObject | ForEach-Object {
    $id = $_.id -replace '^id', ''
    $version = "version=$($_.version)"
    $chip = if ($_.chip) { ",chip=$($_.chip)" }
    $language = if ($_.language) { ",language=$($_.language)" }
    
    # Create the directory name format
    $directoryName = "$id,$version$chip$language"

    # Create the directory
    New-Item -ItemType Directory -Path ".\$directoryName" -Force
}


Pause