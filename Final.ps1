Add-Type -AssemblyName System.Windows.Forms

# Create FolderBrowserDialog
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Select a target folder"
$folderBrowser.ShowNewFolderButton = $false
$folderBrowser.SelectedPath = Get-Location

# Definitions
$foldersTable = @()
$packagesTable = @()
$diffTable = @()
$idRegex = '(.+?)(?:,|$)'
$versionRegex = 'version=(.+?)(?:,|$)'
$chipRegex = 'chip=(.+?)(?:,|$)'
$languageRegex = 'language=(.+?)(?:,|$)'

# Show the dialog and check if the user clicked OK
if ($folderBrowser.ShowDialog() -eq 'OK') {
    # Get the selected folder path
    $targetFolder = $folderBrowser.SelectedPath

    if (Test-Path (Join-Path $targetFolder "Catalog.json") -PathType Leaf) {
        # Process each folder using the pipeline and ForEach-Object
        $foldersTable = Get-ChildItem -Path $targetFolder -Directory | ForEach-Object {
            $inputString = $_.Name

            # Extract information using regular expressions
            $id = if ($inputString -match $idRegex) { $matches[1] } else { $null }
            $version = if ($inputString -match $versionRegex) { $matches[1] } else { $null }
            $chip = if ($inputString -match $chipRegex) { $matches[1] } else { $null }
            $language = if ($inputString -match $languageRegex) { $matches[1] } else { $null }

            # Create hashtable and output it
            [PSCustomObject]@{
                'id'       = $id
                'version'  = $version
                'chip'     = $chip
                'language' = $language
            }
        }
        # Display the output in a tabular format with specified property order
        #$foldersTable | Select-Object id, version, chip, language | Format-Table -AutoSize

        # Read the content of catalog.json
        $jsonContent = Get-Content -Path $targetFolder\Catalog.json -Raw

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
    
        #$packagesTable | Select-Object id, version, chip, language | Format-Table -AutoSize 


        $diffTable = Compare-Object -ReferenceObject $packagesTable -DifferenceObject $foldersTable -Property id, version, chip, language |
        Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -Property id, version, chip, language

        $diffTable

    }
}
else {
    Write-Host "Folder selection canceled."
}


Pause