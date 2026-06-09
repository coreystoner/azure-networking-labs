// =============================================================================
// Module 05: Azure Firewall
// Azure Networking Labs
// =============================================================================
//
// Deploys Azure Firewall in the hub VNet with a Firewall Policy containing
// sample network rules and application rules.
//
// IMPORTANT: This template costs approximately $1.25-1.50/hr.
//            Run cleanup.ps1 -ModuleOnly immediately after completing validation.
//
// Prerequisite: Module 01 (vnet-hub with 10.0.0.0/16 address space).
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// ---------------------------------------------------------------------------
// AzureFirewallSubnet
// Azure Firewall requires a subnet named exactly 'AzureFirewallSubnet'.
// Minimum size: /26 (64 addresses). We use 10.0.4.0/26.
// The private IP will be 10.0.4.4 (Azure assigns the fourth address).
// ---------------------------------------------------------------------------
resource subnetFirewall 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.4.0/26'
  }
}

// ---------------------------------------------------------------------------
// Public IP for the firewall
// ---------------------------------------------------------------------------
resource pipFirewall 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-afw-hub'
  location: location
  tags: { lab: 'azure-networking-labs', module: '05-azure-firewall' }
  sku: { name: 'Standard', tier: 'Regional' }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// ---------------------------------------------------------------------------
// Firewall Policy
// Using Policy (vs Classic rules) — recommended for new deployments.
// ---------------------------------------------------------------------------
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' = {
  name: 'afwp-hub'
  location: location
  tags: { lab: 'azure-networking-labs', module: '05-azure-firewall' }
  properties: {
    sku: { tier: 'Standard' }
    threatIntelMode: 'Alert'
  }
}

// ---------------------------------------------------------------------------
// Rule Collection Group: Lab Rules
// Priority 200 (lower number = higher priority in policy)
// ---------------------------------------------------------------------------
resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = {
  parent: firewallPolicy
  name: 'lab-rules'
  properties: {
    priority: 200
    ruleCollections: [
      // Network Rule Collection: allow specific internal traffic
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
            sourceAddresses: ['10.0.2.0/24']   // snet-app
            destinationAddresses: ['10.0.3.0/24'] // snet-data
            destinationPorts: ['1433']            // SQL Server
          }
        ]
      }
      // Application Rule Collection: allow FQDN-based outbound
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

// ---------------------------------------------------------------------------
// Azure Firewall
// ---------------------------------------------------------------------------
resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: 'afw-hub'
  location: location
  tags: { lab: 'azure-networking-labs', module: '05-azure-firewall' }
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

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output firewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
output firewallPublicIp  string = pipFirewall.properties.ipAddress
output firewallId        string = azureFirewall.id
