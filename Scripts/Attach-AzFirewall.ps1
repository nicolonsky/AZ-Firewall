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

# get Virtual Network Subnet where we want to attach the Azure Firewall
$addressPrefix = (Get-AzVirtualNetworkSubnetConfig -Name $clientSubnet -VirtualNetwork (Get-AzVirtualNetwork -Name $spokeVnet)).AddressPrefix

# allocate firewall based on public ip and vnet
$firewall = Get-AzFirewall -ResourceGroupName $resourceGroupName -Name $azFirewallName
$publicIpAddress = Get-AzPublicIpAddress -Name $publicIpName
$vnet = Get-AzVirtualNetwork -Name $hubVnet

$firewall.Allocate($vnet, $publicIpAddress)
#$firewall.Sku.Tier="Premium"

Write-Output ("Allocating Azure Firewall {0}" -f $azFirewallName)

$firewall | Set-AzFirewall

# Attach Azure Firewall to Subnet
$vnet = Get-AzVirtualNetwork -Name $spokeVnet
$routeTable = Get-AzRouteTable -ResourceGroupName $resourceGroupName -Name $routeTableName
Set-AzVirtualNetworkSubnetConfig -Name $clientSubnet -VirtualNetwork $vnet -RouteTable $routeTable -AddressPrefix $addressPrefix | Set-AzVirtualNetwork
