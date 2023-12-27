# Sample data
$foldersTable = @(
    [PSCustomObject]@{ id = 1; version = '1.0'; chip = 'x86'; language = 'en' },
    [PSCustomObject]@{ id = 2; version = '2.0'; chip = 'x64'; language = 'es' }
    # Add more rows as needed
)

$packagesTable = @(
    [PSCustomObject]@{ id = 1; version = '1.0'; chip = 'x86'; language = 'en' },
    [PSCustomObject]@{ id = 2; version = '2.0'; chip = 'x64'; language = 'fr' },
    [PSCustomObject]@{ id = 3; version = '3.0'; chip = 'arm'; language = 'de' }
    # Add more rows as needed
)

# Initialize diffTable
#$diffTable = @()

# Compare tables
# Use Compare-Object to find differences
$diffTable = Compare-Object -ReferenceObject $packagesTable -DifferenceObject $foldersTable -Property id, version, chip, language |
    Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -Property id, version, chip, language

# Display diffTable
$diffTable


