<#
    .SYNOPSIS
    Retrieve all snapshots and delete them if they are older than (x) days. Current days are set to 14. 

    .DESCRIPTION  
    This script will retrieve all snapshots and delete them if they are older than 14 days across all subscriptions in a tenant. This is because the snapshots are not deleted automatically by the system.
    Using this in a dev or test environment is recommended to optimize operational hygine and keep costs down.

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

    # Enumerate each snapshot 
    $RGs = Get-AzResourceGroup

    foreach ($RG in $RGs) {
    
        $Snapshots = Get-AzSnapshot -ResourceGroupName $RG.ResourceGroupName
    
        foreach ($Snapshot in $Snapshots) {
    
            $Name = $Snapshot.Name
            $ResourceGroupName = $Snapshot.ResourceGroupName

            # If the snapshot was taken in the last 14 days do nothing 
            if ($Snapshot.TimeCreated -gt (Get-Date).AddDays(-0)) {
                $Result.Add([PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    ResourceGroupName = $ResourceGroupName
                    Name = $Name
                    TimeCreated = $Snapshot.TimeCreated
                    Status = "Skipped"
                })
            }
            #If snapshot is older than 14 days delete it
            else {
                Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $Name -Force
                $Result.Add([PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    ResourceGroupName = $ResourceGroupName
                    Name = $Name
                    TimeCreated = $Snapshot.TimeCreated
                    Status = "Deleted"
                })
            }

        }
    }

    #Add the  results to resulting List
    $Result.Add($Obj)
}
$Result
