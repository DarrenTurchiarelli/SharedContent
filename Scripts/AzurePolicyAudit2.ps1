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

#Login to Azure tenant
Connect-AzAccount 

#Get all Subscriptions in your tenant
$allSubscriptions = Get-AzSubscription

#Iterate Subscriptions
foreach($currentSubscription in $allSubscriptions)
{
    #Set Context to the current subscription
    Set-AzContext -SubscriptionName $currentSubscription.Name

    #Iterate custom policies
    $policies = Get-AzPolicyAssignment | Select-Object -ExpandProperty properties | Select-Object -Property DisplayName
    
    $fileName = ".\" + $currentSubscription.Name + "_policies.csv"
    
    $policies | Export-Csv -Path $fileName -NoTypeInformation
}
