<#
.SYNOPSIS
Service principal secret and certificate expiry notification 

.DESCRIPTION
Check weekly service principals due to expire and post to a Microsoft Teams channel

.INPUTS
Microsoft Teams URI  (LINE 33)

.OUTPUTS
Microsoft Teams card 

.NOTES
Version         : 1.0
Author(s)       : Darren Turchiarelli
Creation date   : 07-11-2022
Last Modified   : 10/11/2022

#>

#Connect using Managed Identity
#$SMI = Connect-AzAccount -identity

#Connect using an explicit user account
$USER                  = Connect-AzAccount

#Set the number of days before the service principal is set to expire
$ExpiresInDays        = 15
#Set the grace period in terms of the number of days before the service principal will expire. This is done to prevent alerts from Terraform workspaces which are configured to roll over every 3 days for sending false positives 
$MiddleExpiry         = 3

$uri                  = '<INSERT MICROSOFT TEAMS URI HERE>'
$ArrayTable           = New-Object 'System.Collections.Generic.List[System.Object]'
$applications         = Get-AzADApplication
$servicePrincipals    = Get-AzADServicePrincipal
$results              = @()          
$appWithCredentials   = @()
$appWithCredentials += $applications | Sort-Object -Property DisplayName | foreach {
    $application = $_
    Write-Verbose ('Fetching information for application {0}' -f $application.DisplayName)

    $application | Get-AzADAppCredential -ErrorAction SilentlyContinue | Select-Object -Property `
    @{Name = 'DisplayName'; Expression = { $application.DisplayName}},
    @{Name = 'ObjectId'; Expression = { $application.Id}},
    @{Name = 'AppId'; Expression = { $application.AppId}},
    @{Name = 'KeyId'; Expression = { $_.KeyId}},
    @{Name = 'Type'; Expression = { $_.Type}},
    @{Name = 'StartDateTime'; Expression = { $_.StartDateTime -as [datetime]}},
    @{Name = 'EndDateTime'; Expression = { $_.EndDateTime -as [datetime]}}
}

Write-Output 'Validating expiration data'
$today = (Get-Date).ToUniversalTime()
$limitDate = $today.AddDays($ExpiresInDays)
$middleDate = $today.AddDays($MiddleExpiry)
Write-Output $limitDate
$appWithCredentials | Sort-Object EndDateTime | foreach {
    if ($_.EndDateTime -lt $today) {
        $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Expired'
    }
    elseif ($_.EndDateTime -le $limitDate -and $_.EndDateTime -ge $middleDate) {
        $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Expiring'
    }
    else {
        $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Valid'
    }
}

$appWithCredentials | foreach {
    $results += [PSCustomObject] @{
        CredentialType  = $_.Type;
        DisplayName     = $_.DisplayName;
        ExpiryDate      = $_.EndDateTime;
        StartDateTime   = $_.StartDateTime;
        KeyID           = $_.KeyId;
        AppID           = $_.AppId;
        Status          = $_.Status
    }
}

$appsexpiring = $results | Where-Object {$_.Status -like "Expiring"}
Write-Output $appsexpiring

#Check if there are Service Principals expiring soon, if not then do not post it in Microsoft Teams
if ($appsexpiring -eq $null) {
    Write-Output "No Service Principals expiring before $limitDate"
}
else {
    $appsexpiring | foreach {
        $Section = @{
            facts            = @(
                @{
                    name = 'Service Principal:'
                    value = $_.DisplayName
                },
                @{
                    name = 'Expiry date:'
                    value = $_.ExpiryDate.ToString()
                },
                @{
                    name = 'Application ID:'
                    value = $_.AppId;
                },
                @{
                    name = 'Status:'
                    value = $_.Status
                } 
            )
        }
        $ArrayTable.add($section)
    }
    $Body = ConvertTo-Json -Depth 10 @{
        title       = "Service principal expiry notification"
        text        = "Please validate the secret or certificate for the following service principals and cycle if required"
        sections    = $ArrayTable
    }
    Write-Output "Sending expiring Service principals to Microsoft Teams"
    Invoke-RestMethod -Method Post -ContentType 'application/json' -Body $Body -Uri $uri 
}
