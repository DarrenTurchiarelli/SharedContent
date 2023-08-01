#### The simplest query to get started with Azure firewall logs and retrieve the categories.
```OQL
AzureDiagnostics
|where Category == "AzureFirewallNetworkRule"
```

#### To count the number of log items.
```OQL
AzureDiagnostics
|where Category == "AzureFirewallNetworkRule"
|summarize count()
```

#### If you have more than one Azure Firewall and you want to retrieve logs from a single firewall.
```OQL
AzureDiagnostics
|where Category == "AzureFirewallNetworkRule"
 and Resource == "<insert-firewall-name>"
```

#### Query only the deny logs in the last 24 hours.
```OQL
AzureDiagnostics 
|where TimeGenerated > ago(24h)
 and Category == "AzureFirewallNetworkRule"
 and msg_s contains "Deny" 
```
#### Query denied traffic from a specific IP address.
```OQL
AzureDiagnostics 
|where ResourceType == "AZUREFIREWALLS"
 and msg_s contains "request from <insert-ip-address>"
 and msg_s contains "Deny"
```