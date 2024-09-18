# Config
$resourceGroupName = 'rg-hub-connectivity-nw-prd-szn-01'
$azFirewallName = 'fir-hub-nw-prd-szn-01'
$hubVnet = 'vnet-hub-nw-prd-szn-01'
$spokeVnet = 'vnet-spoke-id-prd-szn-01'
$clientSubnet = 'snet-paw0-tier0-id-prd-szn-01'
$publicIpName = 'fwpubip'
$routeTableName = 'rt-hub-firewall-prd-szn-01'

# Connect to Azure with system-assigned managed identity
Disable-AzContextAutosave -Scope Process
$azureContext = (Connect-AzAccount -Identity).context
$azureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

# Detach Azure Firewall from Subnet
Set-AzVirtualNetworkSubnetConfig -Name $clientSubnet -VirtualNetwork (Get-AzVirtualNetwork -Name $spokeVnet) -RouteTableId $null -AddressPrefix $addressPrefix | Set-AzVirtualNetwork

# Deallocate Azure Firewall
$fw = Get-AzFirewall -ResourceGroupName $resourceGroupName -Name $azFirewallName
$fw.Deallocate()
$fw | Set-AzFirewall