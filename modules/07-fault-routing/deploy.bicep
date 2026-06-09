// =============================================================================
// Module 07: Fault Lab — Routing
// Azure Networking Labs
// =============================================================================
//
// INTENTIONAL MISCONFIGURATION: route-to-internet has nextHopType 'None' (blackhole).
// Fix: Change nextHopType to 'Internet'.
//
// =============================================================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Session key used to generate a unique unlock code. Auto-generated on each deployment.')
param sessionKey string = newGuid()

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// rt-web-fault: primary resource — carries sessionKey tag for validation
resource rtFault 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-web-fault'
  location: location
  tags: { lab: 'azure-networking-labs', module: '07-fault-routing', fault: 'blackhole-route', sessionKey: take(toUpper(sessionKey), 8) }
  properties: {
    routes: [
      {
        name: 'route-to-internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'None'  // <-- BUG: should be 'Internet'
        }
      }
      {
        name: 'route-vnet-local'
        properties: {
          addressPrefix: '10.0.0.0/16'
          nextHopType: 'VnetLocal'
        }
      }
    ]
  }
}

resource subnetFault 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-web-fault2'
  properties: {
    addressPrefix: '10.0.11.0/24'
    routeTable: { id: rtFault.id }
  }
  dependsOn: [rtFault]
}

output rtFaultId     string = rtFault.id
output subnetFaultId string = subnetFault.id
