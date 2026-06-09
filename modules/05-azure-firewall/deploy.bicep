// =============================================================================
// Module 05: Azure Firewall
// Azure Networking Labs
// =============================================================================
//
// IMPORTANT: This template costs approximately $1.25-1.50/hr.
//            Run cleanup.ps1 -ModuleOnly immediately after completing validation.
//
// Prerequisite: Module 01 (vnet-hub with 10.0.0.0/16 address space).
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

@description('Session key used to generate a unique unlock code. Auto-generated on each deployment.')
param sessionKey string = newGuid()

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

resource subnetFirewall 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.4.0/26'
  }
}

resource pipFirewall 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-afw-hub'
  location: location
  tags: { lab: 'azure-networking-labs', module: '05-azure-firewall' }
  sku: { name: 'Standard', tier: 'Regional' }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' = {
  name: 'afwp-hub'
  location: location
  tags: { lab: 'azure-networking-labs', module: '05-azure-firewall' }
  properties: {
    sku: { tier: 'Standard' }
    threatIntelMode: 'Alert'
  }
}

resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = {
  parent: firewallPolicy
  name: 'lab-rules'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'network-rules'
        priority: 100
        action: { type: 'Allow' }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'allow-dns-outbound'
            ipProtocols: ['UDP']
            sourceAddresses: ['10.0.0.0/16', '10.1.0.0/16']
            destinationAddresses: ['*']
            destinationPorts: ['53']
          }
          {
            ruleType: 'NetworkRule'
            name: 'allow-app-to-data-sql'
            ipProtocols: ['TCP']
            sourceAddresses: ['10.0.2.0/24']
            destinationAddresses: ['10.0.3.0/24']
            destinationPorts: ['1433']
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'app-rules'
        priority: 200
        action: { type: 'Allow' }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'allow-microsoft-updates'
            sourceAddresses: ['10.0.0.0/8']
            protocols: [
              { protocolType: 'Https', port: 443 }
              { protocolType: 'Http', port: 80 }
            ]
            targetFqdns: [
              '*.microsoft.com'
              '*.windows.com'
              '*.azure.com'
            ]
          }
        ]
      }
    ]
  }
}

// afw-hub: primary resource — carries sessionKey tag for validation
resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: 'afw-hub'
  location: location
  tags: { lab: 'azure-networking-labs', module: '05-azure-firewall', sessionKey: take(toUpper(sessionKey), 8) }
  dependsOn: [subnetFirewall, ruleCollectionGroup]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: { id: firewallPolicy.id }
    ipConfigurations: [
      {
        name: 'fw-ipconfig'
        properties: {
          subnet: { id: subnetFirewall.id }
          publicIPAddress: { id: pipFirewall.id }
        }
      }
    ]
  }
}

output firewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
output firewallPublicIp  string = pipFirewall.properties.ipAddress
output firewallId        string = azureFirewall.id
