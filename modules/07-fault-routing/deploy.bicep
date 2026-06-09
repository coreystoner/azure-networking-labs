// =============================================================================
// Module 07: Fault Lab — Routing
// Azure Networking Labs
// =============================================================================
//
// INTENTIONAL MISCONFIGURATION: This template deploys a broken route table.
//
// The fault: The route to 0.0.0.0/0 (all internet traffic) has nextHopType
// 'None', which creates a blackhole. All outbound internet traffic is silently
// dropped.
//
// The fix: Update the route's nextHopType to 'Internet'.
//
// =============================================================================

@description('Azure region.')
param location string = resourceGroup().location

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// ---------------------------------------------------------------------------
// Fault subnet: uses a separate subnet to not conflict with Module 04's routes
// ---------------------------------------------------------------------------
resource subnetFault 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-web-fault2'
  properties: {
    addressPrefix: '10.0.11.0/24'
    routeTable: { id: rtFault.id }
  }
  dependsOn: [rtFault]
}

// ---------------------------------------------------------------------------
// Broken Route Table
//
// FAULT: route-to-internet has nextHopType 'None'
//        This creates a blackhole — all internet-bound traffic is dropped.
//        The correct value is 'Internet'.
// ---------------------------------------------------------------------------
resource rtFault 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-web-fault'
  location: location
  tags: { lab: 'azure-networking-labs', module: '07-fault-routing', fault: 'blackhole-route' }
  properties: {
    routes: [
      {
        name: 'route-to-internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'None'  // <-- THIS IS THE BUG. Should be 'Internet'.
        }
      }
      {
        // This route is correct — internal VNet traffic stays local
        name: 'route-vnet-local'
        properties: {
          addressPrefix: '10.0.0.0/16'
          nextHopType: 'VnetLocal'
        }
      }
    ]
  }
}

output rtFaultId     string = rtFault.id
output subnetFaultId string = subnetFault.id
