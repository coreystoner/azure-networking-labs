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

// The hub VNet address space: 10.0.0.0/16 gives us 65,531 usable addresses
// spread across up to 256 /24 subnets. We start with three and leave room
// for subnets added in later modules (firewall, gateway, etc.).
@description('Address prefix for the hub VNet.')
param hubAddressPrefix string = '10.0.0.0/16'

// ---------------------------------------------------------------------------
// Hub Virtual Network
// ---------------------------------------------------------------------------
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-hub'
  location: location
  tags: {
    lab: 'azure-networking-labs'
    module: '01-vnets-subnets'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressPrefix
      ]
    }
    subnets: [
      // Web tier: public-facing workloads (load balancers, reverse proxies)
      // CIDR: 10.0.1.0/24  →  251 usable addresses
      {
        name: 'snet-web'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      // App tier: internal business logic and APIs
      // CIDR: 10.0.2.0/24  →  251 usable addresses
      {
        name: 'snet-app'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      // Data tier: databases, caches, storage endpoints
      // CIDR: 10.0.3.0/24  →  251 usable addresses
      {
        name: 'snet-data'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Outputs — used to reference this VNet in Module 02 and later
// ---------------------------------------------------------------------------
@description('The name of the deployed hub VNet.')
output vnetName string = hubVnet.name

@description('The resource ID of the hub VNet.')
output vnetId string = hubVnet.id

@description('The address space of the hub VNet.')
output vnetAddressSpace string = hubVnet.properties.addressSpace.addressPrefixes[0]

@description('Resource ID of snet-web.')
output subnetWebId string = hubVnet.properties.subnets[0].id

@description('Resource ID of snet-app.')
output subnetAppId string = hubVnet.properties.subnets[1].id

@description('Resource ID of snet-data.')
output subnetDataId string = hubVnet.properties.subnets[2].id
