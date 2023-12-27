# Read the content of catalog.json
$jsonContent = Get-Content -Path .\Catalog.json -Raw

# Convert JSON content to PowerShell object
$catalogObject = $jsonContent | ConvertFrom-Json

# Extract and filter relevant information from the "packages" array
$filteredPackages = $catalogObject.packages | Where-Object {
    $chipCondition = !$_.PSObject.Properties['chip'] -or $_.chip -eq 'x64' -or $_.chip -eq 'neutral' -or $_.chip -eq 'arm64'
    $machineArchCondition = !$_.PSObject.Properties['machineArch'] -or $_.machineArch -eq 'arm64'
    $languageCondition = !$_.PSObject.Properties['language'] -or $_.'language' -eq 'en-US' -or $_.'language' -eq 'neutral'

    $_.payloads -and $_.payloads.url -and $chipCondition -and $machineArchCondition -and $languageCondition
} | ForEach-Object {
    $package = @{
        'id'       = $_.id
        'version'  = $_.version
        'payloads' = @($_.payloads | Where-Object { $_.url } | ForEach-Object {
                @{
                    'fileName' = $_.fileName
                    'url'      = $_.url
                }
            })
    }

    if ($_.chip) { $package['chip'] = $_.chip }
    if ($_.machineArch) { $package['machineArch'] = $_.machineArch }
    if ($_.language) { $package['language'] = $_.'language' }

    $packagesTable += [PSCustomObject]$package

    $package

    
}

# Convert the filtered object back to JSON
$filteredJson = $filteredPackages | ConvertTo-Json -Depth 10

# Write the filtered JSON to Filtered.json
$filteredJson | Set-Content -Path .\Filtered.json

# Display the array of package hashtables using Select-Object and Format-Table
$packagesTable | Select-Object id, version, chip, language | Format-Table -AutoSize 





#$filteredJson | ForEach-Object {
#    $id = $_.id -replace '^id', ''
#    $version = "version=$($_.version)"
#    $chip = if ($_.chip) { ",chip=$($_.chip)" }
#    $language = if ($_.language) { ",language=$($_.language)" }
    
# Create the directory name format
#    $directoryName = "$id,$version$chip$language"

# Create the directory
#    New-Item -ItemType Directory -Path ".\$directoryName" -Force
#}




Pause