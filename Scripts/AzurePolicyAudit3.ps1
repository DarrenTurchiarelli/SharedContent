<#
.SYNOPSIS
Export a list of all Azure policies assignments per subscription 

.DESCRIPTION
This script will export a list of all Azure policy assignments to CSV on a per subscription basis

.INPUTS
None

.OUTPUTS
Excel workbook

.NOTES
Version         : 1.0
Author(s)       : Darren Turchiarelli
Creation date   : 29/08/2023
Last Modified   : 29/08/2023

#>

# Specify the path to the folder containing the JSON files
$folderPath = "C:\Temp\AzPolicies"

# Specify the path for the CSV output file
$outputCsvFile = "C:\PolicyBasline\Baslinepolicy.csv"

# Initialize an array to store the results
$results = @()

# Get a list of JSON files in the folder
$jsonFiles = Get-ChildItem -Path $folderPath -Filter "*.json"

# Loop through each JSON file and extract properties.displayName and properties.description
foreach ($jsonFile in $jsonFiles) {
    try {
        # Read the JSON content from the file
        $jsonContent = Get-Content -Path $jsonFile.FullName -Raw | ConvertFrom-Json

        # Check if properties.displayName and properties.description exist
        if ($jsonContent.Properties.DisplayName -and $jsonContent.Properties.Description) {
            # Create a custom object to store the result
            $result = [PSCustomObject]@{
                File = $jsonFile.Name
                DisplayName = $jsonContent.Properties.DisplayName
                Description = $jsonContent.Properties.Description
            }

            # Add the result to the array
            $results += $result
        }
    } catch {
        # Handle any errors that may occur during JSON parsing
        Write-Host "Error processing $($jsonFile.Name): $_"
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsvFile -NoTypeInformation

Write-Host "CSV file has been created: $outputCsvFile"
