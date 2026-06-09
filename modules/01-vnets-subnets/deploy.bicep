// =============================================================================
// Module 01: VNets & Subnets
// Azure Networking Labs
// =============================================================================
//
// This template deploys a hub Virtual Network with three subnets representing
// a classic three-tier web application layout.
//
// Concepts demonstrated:
//   • VNet address space definition
//   • Subnet segmentation using CIDR blocks
//   • Azure resource tagging
//   • Bicep outputs for use in subsequent modules
//
// Cost: $0.00/hr  — VNets and subnets are free in Azure.
// =============================================================================

@description('Azure region for all resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Address prefix for the hub VNet.')
param hubAddressPrefix string = '10.0.0.0/16'

@description('Session key used to generate a unique unlock code. Auto-generated on each deployment.')
param sessionKey string = newGuid()

// ---------------------------------------------------------------------------
// Hub Virtual Network
// ---------------------------------------------------------------------------
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-hub'
  location: location
  tags: {
    lab: 'azure-networking-labs'
    module: '01-vnets-subnets'
    sessionKey: take(toUpper(sessionKey), 8)
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-web'
        properties: { addressPrefix: '10.0.1.0/24' }
      }
      {
        name: 'snet-app'
        properties: { addressPrefix: '10.0.2.0/24' }
      }
      {
        name: 'snet-data'
        properties: { addressPrefix: '10.0.3.0/24' }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output vnetName string = hubVnet.name
output vnetId string = hubVnet.id
output vnetAddressSpace string = hubVnet.properties.addressSpace.addressPrefixes[0]
output subnetWebId string = hubVnet.properties.subnets[0].id
output subnetAppId string = hubVnet.properties.subnets[1].id
output subnetDataId string = hubVnet.properties.subnets[2].id
