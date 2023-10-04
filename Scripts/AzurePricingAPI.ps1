<#
.SYNOPSIS
This script will query the Azure Pricing API and return a CSV file containing pricing information for all Azure virtual machines in the Australia East region.

.DESCRIPTION
This script will query the Azure Pricing API and return a CSV file containing pricing information for all Azure virtual machines in the Australia East region. As part of the output, the script will also include pricing information for 1, 3 and 5 year Azure Reserved Instances.

.INPUTS
None

.OUTPUTS
CSV file containing Azure pricing information

.NOTES
Version         : 1.0
Author(s)       : Darren Turchiarelli
Creation date   : 04/10/2023
Last Modified   : 05/10/2023

#>
# Define the URL and headers
$url = "https://prices.azure.com/api/retail/prices"
$params = @{
    'api-version' = '2023-01-01-preview'
    'currencyCode' = 'AUD'
    '$filter' = "armRegionName eq 'australiaeast' and serviceName eq 'Virtual Machines'"
}

# Send a GET request to the URL
$response = Invoke-RestMethod -Uri $url -Method Get -Body $params

# Check for a successful response
if ($response) {
    $items = $response.Items
    $data = @()

    foreach ($item in $items) {
        # Convert the item to a PSCustomObject
        $obj = [PSCustomObject]@($item | ConvertTo-Json -Depth 10 | ConvertFrom-Json)

        # Initialize all potential columns with null values
        $newProperties = @{
            "1_year_term_unit_price" = $null
            "1_year_term_retail_price" = $null
            "3_year_term_unit_price" = $null
            "3_year_term_retail_price" = $null
            "5_year_term_unit_price" = $null
            "5_year_term_retail_price" = $null
        }

        # Add new properties to object
        $obj = $obj | Add-Member -NotePropertyMembers $newProperties -PassThru

        # Populate the fields as necessary
        $savingsPlan = $item.savingsPlan
        if ($savingsPlan -ne $null) {
            foreach ($plan in $savingsPlan) {
                switch ($plan.term) {
                    "1 Year" {
                        $obj."1_year_term_unit_price" = $plan.unitPrice
                        $obj."1_year_term_retail_price" = $plan.retailPrice
                    }
                    "3 Years" {
                        $obj."3_year_term_unit_price" = $plan.unitPrice
                        $obj."3_year_term_retail_price" = $plan.retailPrice
                    }
                    "5 Years" {
                        $obj."5_year_term_unit_price" = $plan.unitPrice
                        $obj."5_year_term_retail_price" = $plan.retailPrice
                    }
                }
            }
        }

        $data += $obj
    }

    $data | Select-Object currencyCode, tierMinimumUnits, retailPrice, unitPrice, armRegionName, location, effectiveStartDate, meterId, meterName, productId, skuId, productName, skuName, serviceName, serviceId, serviceFamily, unitOfMeasure, type, isPrimaryMeterRegion, armSkuName, '1_year_term_unit_price', '1_year_term_retail_price', '3_year_term_unit_price', '3_year_term_retail_price', '5_year_term_unit_price', '5_year_term_retail_price' | Export-Csv -Path "Azure_Pricing.csv" -NoTypeInformation

}
