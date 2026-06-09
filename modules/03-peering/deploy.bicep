// =============================================================================
// Module 03: VNet Peering
// Azure Networking Labs
// =============================================================================
//
// Prerequisite: Module 01 (vnet-hub) must be deployed.
// Cost: $0.00/hr
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

@description('Session key used to generate a unique unlock code. Auto-generated on each deployment.')
param sessionKey string = newGuid()

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// vnet-spoke1: primary resource — carries sessionKey tag for validation
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-spoke1'
  location: location
  tags: { lab: 'azure-networking-labs', module: '03-peering', sessionKey: take(toUpper(sessionKey), 8) }
  properties: {
    addressSpace: {
      addressPrefixes: ['10.1.0.0/16']
    }
    subnets: [
      {
        name: 'snet-workloads'
        properties: { addressPrefix: '10.1.1.0/24' }
      }
    ]
  }
}

resource peeringHubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: 'peer-hub-to-spoke1'
  properties: {
    remoteVirtualNetwork: { id: spokeVnet.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource peeringSpokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: spokeVnet
  name: 'peer-spoke1-to-hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnet.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

output spokeVnetId   string = spokeVnet.id
output spokeVnetName string = spokeVnet.name
