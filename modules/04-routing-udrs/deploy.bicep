// =============================================================================
// Module 04: Routing & User Defined Routes
// Azure Networking Labs
// =============================================================================
//
// Prerequisite: Module 01 (vnet-hub) must be deployed.
// Cost: $0.00/hr  — Route tables are free.
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

@description('IP address of the hub network appliance (NVA or Azure Firewall).')
param hubApplianceIp string = '10.0.4.4'

@description('Session key used to generate a unique unlock code. Auto-generated on each deployment.')
param sessionKey string = newGuid()

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// rt-web: primary resource — carries sessionKey tag for validation
resource rtWeb 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-web'
  location: location
  tags: { lab: 'azure-networking-labs', module: '04-routing-udrs', sessionKey: take(toUpper(sessionKey), 8) }
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

resource rtData 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-data'
  location: location
  tags: { lab: 'azure-networking-labs', module: '04-routing-udrs' }
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'blackhole-internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'None'
        }
      }
    ]
  }
}

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

output rtWebId  string = rtWeb.id
output rtAppId  string = rtApp.id
output rtDataId string = rtData.id
