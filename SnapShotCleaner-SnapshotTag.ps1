<#
    .SYNOPSIS
    Retrieve all snapshots and delete them if they are older than 14 days and have a tag "Environment = Development".

    .DESCRIPTION  
    This script will retrieve all snapshots and delete them if they are older than 14 days. This is because the snapshots are not deleted automatically by the system.
    Using this in a dev or test environment is recommended to optimize operational hygine and keep costs down.
    As a safety blanket it will only delete the snapshot if there is a tag "Environment = Development" on the snapshot.

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

            # If the snapshot was taken in the last 14 days and has the tag "Environment = Development" skip
            if ($Snapshot.TimeCreated -gt (Get-Date).AddDays(-0) -and $Snapshot.Tags.Environment -eq "Development") {
                $Result.Add([PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    ResourceGroupName = $ResourceGroupName
                    Name = $Name
                    TimeCreated = $Snapshot.TimeCreated
                    Status = "Skipped"
                })
            }
   
            #Else snapshot is older than 14 days and has the tag "Environment = Development" delete it
            elseif ($Snapshot.TimeCreated -lt (Get-Date).AddDays(-0) -and $Snapshot.Tags.Environment -eq "Development") {
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
