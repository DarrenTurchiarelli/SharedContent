# Create Azure Service Health Alerts for All Resource Groups - Microsoft Tech Community
# https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/create-azure-service-health-alerts-for-all-resource-groups/ba-p/3610252

# This has been built with some modifications based on the original work authored by Werner Rall

#Log in to Azure account
# Connect-AzAccount

#Get list of Azure Subscription ID's
$Subs = get-AzSubscription -SubscriptionId '728f99b5-49fe-47b9-9bcd-97d981ccdfa9'


#Loop through the subscriptions to find all Resource Groups and create the Service Health Alerts
$Subs | ForEach-Object -Parallel {
Write-Host "Switching Subscriptions"
Set-AzContext -SubscriptionId $_.Id

Write-Host "Getting all Resource Groups"
$AllRGs = (Get-AzResourceGroup).ResourceGroupName

    foreach($rg in $AllRGs){
        #For each IAM the RG until you find an email address for either Owner or Contributor
        $rContributors = Get-AzRoleAssignment -ResourceGroupName $rg -RoleDefinitionName 'Contributor' | where-object SignInName -NE $null | Select-Object SignInName | Sort-Object ResourceType -Unique
        $rOwners = Get-AzRoleAssignment -ResourceGroupName $rg -RoleDefinitionName 'Owner' | Where-Object SignInName -NE $null | Select-Object SignInName | Sort-Object ResourceType -Unique
        Write-Host "Search for Contributors in the " + $rg + " Resource Group"

         if ($rContributors.SignInName -ne $null) {
            Write-Host "Contributors Found in the Resource Group, building an Array"
            $contactemailadress = $rContributors.SignInName
         }
         elseif ($rOwners.SignInName -ne $null) {
            Write-Host "No Contributors found, looking for Owners"
            $contactemailadress = $rOwners.SignInName
            Write-Host "Owners Found in the Resource Group, building an Array"
         }else {
            Write-Host "No Valid Contributors or Owners found for $rg"
         }
        
        #(Needs to be idempotent) Create Service Health Alerts
        Write-Host "Generating some numbers"
        $randomnumber = Get-Random -Minimum 1000 -Maximum 9999
        $actionGroupName = $rg + "actionGroup" + $randomnumber
        $actionGroupShortName = "action" + $randomnumber
        $activityLogAlertName = "serviceHealthAlert" + $randomnumber

        #Create Health Alert Option 1
        foreach($ctact in $contactemailadress){
        Write-Host "Creating a Health Alert for $ctact"
        New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateUri 'https://raw.githubusercontent.com/DarrenTurchiarelli/SharedContent/main/Scripts/ServiceHealth/ResourceHealthAlertTemplate.json' `
        -actionGroupName $actionGroupName -actionGroupShortName $actionGroupShortName -activityLogAlertName $activityLogAlertName -emailAddress $ctact
        }
    
    $output = "Service Health Alerts have been created for your " + $_.Name + " subscription"
    $output   
 }
}
