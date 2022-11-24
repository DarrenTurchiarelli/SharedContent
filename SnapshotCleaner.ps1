<#
    .SYNOPSIS
    Retrieve all snapshots and delete them if they are older than 14 days.

    .DESCRIPTION  
    This script will retrieve all snapshots and delete them if they are older than 14 days. This is because the snapshots are not deleted automatically by the system.
    Using this in a dev or test environment is recommended to keep the storage space under control as well as keep costs down.

    .LINK
     https://learn.microsoft.com/en-us/azure/virtual-machines/snapshot-copy-managed-disk?tabs=portal

    .NOTES
    Create a function app or runbook in Azure Automation to run this script.
    
#>

#Create a list to store all results
$Result=New-Object System.Collections.Generic.List[PSObject]

#Retrieve all Azure Subscriptions
$Subscriptions = Get-AzSubscription

#Loop through all subscriptions
foreach ($sub in $Subscriptions) {

    #Set the context so the script will be executed within each subscriptions scope
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

    #Insert your code here for what you want run across every subscription 
    $RGs = Get-AzResourceGroup

    foreach ($RG in $RGs) {
    
        $Snapshots = Get-AzSnapshot -ResourceGroupName $RG.ResourceGroupName
    
        foreach ($Snapshot in $Snapshots) {
    
            $Name = $Snapshot.Name
            $ResourceGroupName = $Snapshot.ResourceGroupName

            #Only delete snapshots older than 14 days
            if ($Snapshot.TimeCreated -lt (Get-Date).AddDays(-14)) {
                $Result.Add($Snapshot)
                Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $Name -Force
            }

            Write-Output "Deleted $Name - $ResourceGroupName"
        }
    }

    #Add the  results to resulting List
    $Result.Add($Obj)
}
$Result
