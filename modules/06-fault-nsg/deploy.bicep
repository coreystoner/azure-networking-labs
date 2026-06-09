// =============================================================================
// Module 06: Fault Lab — NSG
// Azure Networking Labs
// =============================================================================
//
// INTENTIONAL MISCONFIGURATION: Block-All-Inbound at priority 90 (before Allow-HTTP at 100).
// Fix: Change Block-All-Inbound priority to 4000 or any value > 100.
//
// Note to instructors: This file is the answer key.
// =============================================================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Session key used to generate a unique unlock code. Auto-generated on each deployment.')
param sessionKey string = newGuid()

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// nsg-web-fault: primary resource — carries sessionKey tag for validation
resource nsgFault 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-web-fault'
  location: location
  tags: { lab: 'azure-networking-labs', module: '06-fault-nsg', fault: 'priority-ordering', sessionKey: take(toUpper(sessionKey), 8) }
  properties: {
    securityRules: [
      {
        // BUG: Priority 90 means this rule fires BEFORE Allow-HTTP (priority 100)
        name: 'Block-All-Inbound'
        properties: {
          priority: 90
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          description: 'Catch-all deny rule (misconfigured priority — BUG: should be 4000)'
        }
      }
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
          description: 'Allow HTTP from internet (never reached due to fault)'
        }
      }
    ]
  }
}

resource subnetFault 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-web-fault'
  properties: {
    addressPrefix: '10.0.10.0/24'
    networkSecurityGroup: { id: nsgFault.id }
  }
  dependsOn: [nsgFault]
}

output nsgFaultId    string = nsgFault.id
output subnetFaultId string = subnetFault.id
