<#
.SYNOPSIS
Export a list of all Azure policies and initiatives to a CSV file. 

.DESCRIPTION
This script will export a list of all Azure policies in json format for auditing purposes.

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
    $policies = Get-AzPolicyDefinition | where {$_.Properties.PolicyType -eq 'Custom'}
    
    #Iterate policies
    foreach ($policy in $policies) {
        
        #Getting the policy details
        $policyName = $policy.Name
        $fileName = $currentSubscription.Name + "_" + $policyName + ".json"

        #Exporting the policy to a file
        $policy | ConvertTo-Json -Depth 100 | Out-File ".\$fileName"
    }

}
