@description('Azure Firewall name')
param firewallName string = 'fw${uniqueString(resourceGroup().id)}'

@description('Azure Firewall Policy Name')
param firewallPolicyName string = 'fwpol-avd-nw-prd-szn-01'

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' = {
  name: firewallPolicyName
  location: resourceGroup().location
  properties: {
    threatIntelMode: 'Deny'
    intrusionDetection: {
      mode: 'Deny'
    }
    sku: {
      tier: 'Premium'
    }
    dnsSettings: {
      enableProxy: true
    }
  }
}

resource webCategoryFiltering 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  parent: firewallPolicy
  name: 'Webfiltering-Core'
  properties: {
    priority: 3000
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'Allowed-Web-Categories'
        priority: 3100
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Categories'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            //https://learn.microsoft.com/en-us/azure/firewall/web-categories
            webCategories: [
              'Business'
            ]
            sourceAddresses: [
              '10.10.0.0/16'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Wpninjas'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            targetFqdns: [
              '*.wpninjas.ch'
            ]
            sourceAddresses: [
              '10.10.0.0/16'
            ]
          }
        ]
      }
    ]
  }
}
