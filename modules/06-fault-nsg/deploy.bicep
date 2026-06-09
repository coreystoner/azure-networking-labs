// =============================================================================
// Module 06: Fault Lab — NSG
// Azure Networking Labs
// =============================================================================
//
// INTENTIONAL MISCONFIGURATION: This template deploys a broken NSG.
//
// The fault: A 'Block-All-Inbound' rule is configured at priority 90, which
// is evaluated BEFORE the 'Allow-HTTP-Inbound' rule at priority 100.
// Result: HTTP traffic is blocked despite an 'allow' rule appearing to exist.
//
// The fix: Change Block-All-Inbound priority to 4000 (or any value > 100).
//
// Note to instructors: The fault is documented here intentionally so this
// file serves as the answer key. Learners should not read deploy.bicep before
// attempting to diagnose the issue.
// =============================================================================

@description('Azure region.')
param location string = resourceGroup().location

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// ---------------------------------------------------------------------------
// Fault subnet: snet-web-fault
// A separate subnet so this fault lab doesn't conflict with Module 02's NSG.
// ---------------------------------------------------------------------------
resource subnetFault 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-web-fault'
  properties: {
    addressPrefix: '10.0.10.0/24'
    networkSecurityGroup: { id: nsgFault.id }
  }
  dependsOn: [nsgFault]
}

// ---------------------------------------------------------------------------
// Broken NSG: nsg-web-fault
//
// FAULT: Block-All-Inbound is at priority 90.
//        Allow-HTTP-Inbound is at priority 100.
//        Priority 90 < 100, so the block rule is evaluated first.
//        HTTP traffic is denied before it reaches the allow rule.
// ---------------------------------------------------------------------------
resource nsgFault 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-web-fault'
  location: location
  tags: { lab: 'azure-networking-labs', module: '06-fault-nsg', fault: 'priority-ordering' }
  properties: {
    securityRules: [
      {
        // BUG: Priority 90 means this rule is evaluated BEFORE Allow-HTTP (priority 100)
        name: 'Block-All-Inbound'
        properties: {
          priority: 90              // <-- THIS IS THE BUG. Should be 4000 or similar.
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          description: 'Catch-all deny rule (misconfigured priority)'
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

output nsgFaultId   string = nsgFault.id
output subnetFaultId string = subnetFault.id
