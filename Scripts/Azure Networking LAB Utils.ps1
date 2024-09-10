# Azure Networking LAB Utils

$resourceGroupName = 'rg-hub-connectivity-nw-prd-szn-01'
$azFirewallName = 'fir-hub-nw-prd-szn-01'
$hubVnet = 'vnet-hub-nw-prd-szn-01'
$spokeVnet = 'vnet-spoke-id-prd-szn-01'
$clientSubnet = 'snet-paw0-tier0-id-prd-szn-01'
$publicIpName = 'fwpubip'
$routeTableName = 'rt-hub-firewall-prd-szn-01'
$addressPrefix = (Get-AzVirtualNetworkSubnetConfig -Name $clientSubnet -VirtualNetwork (Get-AzVirtualNetwork -Name $spokeVnet)).AddressPrefix

# Detach Azure Firewall from Subnet
Set-AzVirtualNetworkSubnetConfig -Name $clientSubnet -VirtualNetwork (Get-AzVirtualNetwork -Name $spokeVnet) -RouteTableId $null -AddressPrefix $addressPrefix | Set-AzVirtualNetwork

# Deallocate Azure Firewall
$fw = Get-AzFirewall -ResourceGroupName $resourceGroupName -Name $azFirewallName
$fw.Deallocate()
$fw | Set-AzFirewall

# Allocate Azure Firewall
$fw = Get-AzFirewall -ResourceGroupName $resourceGroupName -Name $azFirewallName
#$fw.Sku.Tier="Premium"
$ip = Get-AzPublicIpAddress -Name $publicIpName
$net = Get-AzVirtualNetwork -Name $subnetName
$fw.Allocate($net, $ip)
$fw | Set-AzFirewall

# Attach Azure Firewall to Subnet
$routeTable = Get-AzRouteTable -ResourceGroupName $resourceGroupName -Name $routeTableName
Set-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $net -RouteTable $routeTable -AddressPrefix $addressPrefix | Set-AzVirtualNetwork

# Dump Rules as JSON
$rules = Get-AzFirewallPolicyRuleCollectionGroup -Name 'Management-URLs' -ResourceGroupName $resourceGroupName -AzureFirewallPolicyName 'fwpolicy'
$rules.Properties.RuleCollection | Select-Object -ExpandProperty RulesText | Set-Content -Path 'C:\Users\NicolaSuter\OneDrive - baseVISION AG\Desktop\Rules-MGMT.json'