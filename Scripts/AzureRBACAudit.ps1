<#
.SYNOPSIS
Audit Azure RBAC assignments and export to Excel

.DESCRIPTION
This script will audit Azure RBAC assignments and export the results to an Excel workbook. The workbook will contain two worksheets, one for subscription RBAC assignments and one for resource group RBAC assignments.

.INPUTS
None

.OUTPUTS
Excel workbook

.NOTES
Version         : 1.0
Author(s)       : Darren Turchiarelli
Creation date   : 18/08/2023
Last Modified   : 18/08/2023

#>
# Update the output path to a valid location
$OutputPath = "C:\Workbench\AzureRBAC.xlsx"

# Create a new Excel workbook
$excel = New-Object -ComObject Excel.Application
$workbook = $excel.Workbooks.Add()

# Create a worksheet for subscription RBAC information
$subscriptionSheet = $workbook.Worksheets.Add()
$subscriptionSheet.Name = "SubscriptionRBAC"
$subscriptionSheet.Cells.Item(1,1).Value = "RoleDefinitionName"
$subscriptionSheet.Cells.Item(1,2).Value = "DisplayName"
$subscriptionSheet.Cells.Item(1,3).Value = "SignInName"
$subscriptionSheet.Cells.Item(1,4).Value = "ObjectType"
$subscriptionSheet.Cells.Item(1,5).Value = "Scope"
$subscriptionSheet.Cells.Item(1,6).Value = "TenantId"
$subscriptionSheet.Cells.Item(1,7).Value = "SubscriptionName"
$subscriptionSheet.Cells.Item(1,8).Value = "SubscriptionId"

# Create a worksheet for resource group RBAC information
$resourceGroupSheet = $workbook.Worksheets.Add()
$resourceGroupSheet.Name = "ResourceGroupRBAC"
$resourceGroupSheet.Cells.Item(1,1).Value = "RoleDefinitionName"
$resourceGroupSheet.Cells.Item(1,2).Value = "DisplayName"
$resourceGroupSheet.Cells.Item(1,3).Value = "SignInName"
$resourceGroupSheet.Cells.Item(1,4).Value = "ObjectType"
$resourceGroupSheet.Cells.Item(1,5).Value = "Scope"
$resourceGroupSheet.Cells.Item(1,6).Value = "TenantId"
$resourceGroupSheet.Cells.Item(1,7).Value = "SubscriptionName"
$resourceGroupSheet.Cells.Item(1,8).Value = "SubscriptionId"
$resourceGroupSheet.Cells.Item(1,9).Value = "ResourceGroupName"

# Get all subscriptions
$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {
    Write-Verbose -Message "Retrieving RBAC information for Subscription $($subscription.Name)" -Verbose

    Set-AzContext -TenantId $subscription.TenantId -SubscriptionId $subscription.Id -Force
    $Name     = $subscription.Name
    $TenantId = $subscription.TenantId
    $SubId    = $subscription.SubscriptionId

    # Retrieve RBAC information for the subscription
    $rbacInfo = Get-AzRoleAssignment -IncludeClassicAdministrators | Select-Object RoleDefinitionName, DisplayName, SignInName, ObjectType, Scope,
        @{Name = "TenantId"; Expression = { $TenantId }},
        @{Name = "SubscriptionName"; Expression = { $Name }},
        @{Name = "SubscriptionId"; Expression = { $SubId }}

    # Add subscription RBAC information to the worksheet
    $row = $subscriptionSheet.UsedRange.Rows.Count + 1
    foreach ($entry in $rbacInfo) {
        $subscriptionSheet.Cells.Item($row, 1).Value = $entry.RoleDefinitionName
        $subscriptionSheet.Cells.Item($row, 2).Value = $entry.DisplayName
        $subscriptionSheet.Cells.Item($row, 3).Value = $entry.SignInName
        $subscriptionSheet.Cells.Item($row, 4).Value = $entry.ObjectType
        $subscriptionSheet.Cells.Item($row, 5).Value = $entry.Scope
        $subscriptionSheet.Cells.Item($row, 6).Value = $entry.TenantId
        $subscriptionSheet.Cells.Item($row, 7).Value = $entry.SubscriptionName
        $subscriptionSheet.Cells.Item($row, 8).Value = $entry.SubscriptionId
        $row++
    }

    # Get resource groups within the subscription
    $resourceGroups = Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups) {
        Write-Verbose -Message "Retrieving RBAC information for Resource Group $($resourceGroup.ResourceGroupName) in Subscription $($subscription.Name)" -Verbose

        # Retrieve RBAC information for the resource group
        $rgRbacInfo = Get-AzRoleAssignment -ResourceGroupName $resourceGroup.ResourceGroupName | Select-Object RoleDefinitionName, DisplayName, SignInName, ObjectType, Scope,
            @{Name = "TenantId"; Expression = { $TenantId }},
            @{Name = "SubscriptionName"; Expression = { $Name }},
            @{Name = "SubscriptionId"; Expression = { $SubId }},
            @{Name = "ResourceGroupName"; Expression = { $resourceGroup.ResourceGroupName }}

        # Add resource group RBAC information to the worksheet
        $row = $resourceGroupSheet.UsedRange.Rows.Count + 1
        foreach ($entry in $rgRbacInfo) {
            $resourceGroupSheet.Cells.Item($row, 1).Value = $entry.RoleDefinitionName
            $resourceGroupSheet.Cells.Item($row, 2).Value = $entry.DisplayName
            $resourceGroupSheet.Cells.Item($row, 3).Value = $entry.SignInName
            $resourceGroupSheet.Cells.Item($row, 4).Value = $entry.ObjectType
            $resourceGroupSheet.Cells.Item($row, 5).Value = $entry.Scope
            $resourceGroupSheet.Cells.Item($row, 6).Value = $entry.TenantId
            $resourceGroupSheet.Cells.Item($row, 7).Value = $entry.SubscriptionName
            $resourceGroupSheet.Cells.Item($row, 8).Value = $entry.SubscriptionId
            $resourceGroupSheet.Cells.Item($row, 9).Value = $entry.ResourceGroupName
            $row++
        }
    }
}

# Save the workbook and close Excel
$workbook.SaveAs($OutputPath)
$workbook.Close($true)
$excel.Quit()

# Release the COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook)
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "Excel workbook saved at $OutputPath"
