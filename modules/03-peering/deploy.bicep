// =============================================================================
// Module 03: VNet Peering
// Azure Networking Labs
// =============================================================================
//
// This template creates a spoke VNet and establishes bidirectional peering
// between the hub VNet (from Module 01) and the new spoke.
//
// Key concepts:
//   • Hub-and-spoke VNet topology
//   • Bidirectional peering (two peering resources required)
//   • Non-overlapping address spaces
//   • Peering options: forwarded traffic, gateway transit
//
// Prerequisite: Module 01 (vnet-hub) must be deployed.
// Cost: $0.00/hr  — peering within the same region is free (no traffic charges
//                    in lab scenarios with no actual data transfer).
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

// Reference the existing hub VNet from Module 01
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// ---------------------------------------------------------------------------
// Spoke VNet
// Uses 10.1.0.0/16 — must NOT overlap with hub (10.0.0.0/16)
// ---------------------------------------------------------------------------
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-spoke1'
  location: location
  tags: { lab: 'azure-networking-labs', module: '03-peering' }
  properties: {
    addressSpace: {
      addressPrefixes: ['10.1.0.0/16']
    }
    subnets: [
      {
        name: 'snet-workloads'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Peering: Hub → Spoke
// Created on the hub VNet. Allows the hub to reach spoke resources.
// ---------------------------------------------------------------------------
resource peeringHubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: 'peer-hub-to-spoke1'
  properties: {
    remoteVirtualNetwork: { id: spokeVnet.id }
    allowVirtualNetworkAccess: true   // Allow VMs in spoke to communicate with hub VMs
    allowForwardedTraffic: true        // Allow forwarded traffic (needed for NVA/firewall scenarios)
    allowGatewayTransit: false         // Set to true when hub has a VPN/ExpressRoute gateway
    useRemoteGateways: false
  }
}

// ---------------------------------------------------------------------------
// Peering: Spoke → Hub
// Created on the spoke VNet. Allows spoke to reach hub resources.
// IMPORTANT: Both directions must be "Connected" for traffic to flow.
// ---------------------------------------------------------------------------
resource peeringSpokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: spokeVnet
  name: 'peer-spoke1-to-hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnet.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false           // Set to true to use hub's VPN/ExpressRoute gateway
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output spokeVnetId   string = spokeVnet.id
output spokeVnetName string = spokeVnet.name
output peeringHubToSpokeState string = peeringHubToSpoke.properties.peeringState
output peeringSpokeToHubState string = peeringSpokeToHub.properties.peeringState
