# Application Gateway Monitoring Dashboard

More info in blog: <https://blogs.technet.microsoft.com/robdavies/2017/12/29/monitoring-application-gateway-with-azure-log-analytics/>

**PLEASE NOTE:** You must deploy this ARM template to the _Resource Group_ in which your Azure Log Analytics (OMS) workspace is located.

## Deploy Dashboard via Portal
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fiamrobdavies%2FMonitoringExamples%2Fmaster%2FApplicationGateway%2FDashboard%2FAppGWDashboard.json")


## Deploy Dashboard via CLI
```
az group deployment create -g LogAnalyticsResourceGroupName --template-file AppGWDashboard.json --parameters '{"logAnalyticsWorkspaceName": {"value":"LogAnalyticsWorkspaceName"},"logAnalyticsWorkspaceResourceGroup":{"value":"LogAnalyticsResourceGroupName"}}' --verbose
```

## Deploy Dashboard via PowerShell
```
New-AzureRmResourceGroupDeployment -ResourceGroupName 'LogAnalyticsResourceGroupName' -TemplateFile .\AppGWDashboard.json -logAnalyticsWorkspaceName 'LogAnalyticsWorkspaceName' -logAnalyticsWorkspaceResourceGroup 'LogAnalyticsResourceGroupName' -Verbose
```

# Deploy Application Gateway with Diagnostic Logging Enabled

The file **AppGwWithDiagnosticsEnabled.json** is an example ARM template to deploy an Azure Applicaiton Gateway.

Using the APIs in *Microsoft.Insights/service*, the Application Gateway is created with the ApplicationGatewayAccessLog and ApplicationGatewayPerformanceLog diagnostic logs enabled.

The file **AppGwWithDiagnosticsEnabled.param.json** is an example of a parameter file, which can be used to deploy AppGwWithDiagnosticsEnabled.json sucessfully.


More info about Application Gateway Diagnostic Logging here: <https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-diagnostics>

https://github.com/iamrobdavies/MonitoringExamples/tree/master/ApplicationGateway/Dashboard

Check out the Application Gateway WAF Triage Workbook

https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20WAF/Workbook%20-%20AppGw%20WAF%20Triage%20Workbook

# Application Gateway WAF Triage Workbook

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Network-Security%2Fmaster%2FAzure%2520WAF%2FWorkbook%2520-%2520AppGw%2520WAF%2520Triage%2520Workbook%2FWAFTriageWorkbook_ARM.json)

This workbook visualizes Application Gateway WAF rule violations and helps with triaging those so to facilitate tuning the WAF against valid traffic.

This workbook is designed to parse WAF logs from Application Gateway WAF V2 configured with WAF Policy.

Often companies struggle to parse the logs from the Application Gateway Web Application Firewall and triage them to determine which ones are true violations and which ones are false positives.  Especially during the design phase of an application, it is important to review these logs and make sure to adapt the application and/or WAF configuration so to eliminate false positives.  This is where this workbook might help.  
 
_For additional information and step by step deployment guide and usage, see this [blogpost in TechCommunity](https://techcommunity.microsoft.com/t5/azure-network-security-blog/introducing-the-application-gateway-waf-triage-workbook/ba-p/2973341)_  
  

## Deploying the Workbook

To deploy this workbook, click the button "Deploy to Azure".  Fill in the requested parameters:

- `Workbook Display Name`: the name of the workbook as it will be shown in the portal
- `Workbook Source Id`: the full Resource ID of the Log Analytics workspace you want to link to workbook to.  Example of a value: /subscriptions/'GUID'/resourcegroups/'RG Name'/providers/microsoft.operationalinsights/workspaces/'Workspace Name'

Then click "Review + create".


_**Note**: If you need to use the transaction ID in the ApplicationGatewayAccessLog, then replace "host_s" with "originalHost_s" in the join between ApplicationGatewayAccessLog and ApplicationGatewayFirewallLog_
