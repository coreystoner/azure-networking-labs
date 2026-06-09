// =============================================================================
// Module 04: Routing & User Defined Routes
// Azure Networking Labs
// =============================================================================
//
// This template creates route tables and associates them with hub VNet subnets.
// Traffic for each subnet tier is directed appropriately:
//
//   snet-web  → rt-web  : Route non-VNet traffic to hub appliance (10.0.4.4)
//   snet-app  → rt-app  : Route non-VNet traffic to hub appliance
//   snet-data → rt-data : Blackhole all outbound internet (None next-hop)
//
// 10.0.4.4 is where Azure Firewall will be deployed in Module 05.
// Until then, this route table exists to demonstrate UDR configuration.
//
// Prerequisite: Module 01 (vnet-hub) must be deployed.
// Cost: $0.00/hr  — Route tables are free.
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

@description('IP address of the hub network appliance (NVA or Azure Firewall).')
param hubApplianceIp string = '10.0.4.4'

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// ---------------------------------------------------------------------------
// Route Table: Web Tier
// Default internet traffic routes through the hub appliance.
// VNet-local traffic uses system routes (no UDR needed for internal).
// ---------------------------------------------------------------------------
resource rtWeb 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-web'
  location: location
  tags: { lab: 'azure-networking-labs', module: '04-routing-udrs' }
  properties: {
    disableBgpRoutePropagation: false  // Allow gateway routes to still propagate
    routes: [
      {
        name: 'route-internet-via-appliance'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: hubApplianceIp
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Route Table: App Tier
// Same forced-tunneling pattern as web tier.
// ---------------------------------------------------------------------------
resource rtApp 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-app'
  location: location
  tags: { lab: 'azure-networking-labs', module: '04-routing-udrs' }
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'route-internet-via-appliance'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: hubApplianceIp
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Route Table: Data Tier
// Data-tier workloads should NEVER communicate directly with the internet.
// "None" next-hop creates a blackhole — all outbound internet traffic is dropped.
// ---------------------------------------------------------------------------
resource rtData 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-data'
  location: location
  tags: { lab: 'azure-networking-labs', module: '04-routing-udrs' }
  properties: {
    disableBgpRoutePropagation: true   // Also disable BGP so no gateway routes leak in
    routes: [
      {
        name: 'blackhole-internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'None'           // Drop all traffic matching this route
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Associate route tables with subnets (updates existing subnets)
// ---------------------------------------------------------------------------
resource subnetWeb 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-web'
  properties: {
    addressPrefix: '10.0.1.0/24'
    routeTable: { id: rtWeb.id }
  }
}

resource subnetApp 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-app'
  dependsOn: [subnetWeb]
  properties: {
    addressPrefix: '10.0.2.0/24'
    routeTable: { id: rtApp.id }
  }
}

resource subnetData 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-data'
  dependsOn: [subnetApp]
  properties: {
    addressPrefix: '10.0.3.0/24'
    routeTable: { id: rtData.id }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output rtWebId  string = rtWeb.id
output rtAppId  string = rtApp.id
output rtDataId string = rtData.id
