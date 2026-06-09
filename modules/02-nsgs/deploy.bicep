// =============================================================================
// Module 02: Network Security Groups
// Azure Networking Labs
// =============================================================================
//
// This template adds NSGs to the hub VNet subnets from Module 01.
//
// Prerequisite: Module 01 (vnet-hub) must be deployed.
// Cost: $0.00/hr  — NSGs are free in Azure.
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

@description('Session key used to generate a unique unlock code. Auto-generated on each deployment.')
param sessionKey string = newGuid()

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// nsg-web: primary resource — carries sessionKey tag for validation
resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-web'
  location: location
  tags: { lab: 'azure-networking-labs', module: '02-nsgs', sessionKey: take(toUpper(sessionKey), 8) }
  properties: {
    securityRules: [
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
        }
      }
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

resource nsgApp 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-app'
  location: location
  tags: { lab: 'azure-networking-labs', module: '02-nsgs' }
  properties: {
    securityRules: [
      {
        name: 'Allow-From-Web-Tier'
        properties: {
          priority: 100
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '10.0.1.0/24'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
      {
        name: 'Deny-All-Other-Inbound'
        properties: {
          priority: 4000
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource nsgData 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-data'
  location: location
  tags: { lab: 'azure-networking-labs', module: '02-nsgs' }
  properties: {
    securityRules: [
      {
        name: 'Allow-From-App-Tier'
        properties: {
          priority: 100
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '10.0.2.0/24'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
      {
        name: 'Deny-All-Other-Inbound'
        properties: {
          priority: 4000
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
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
    networkSecurityGroup: { id: nsgWeb.id }
  }
}

resource subnetApp 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-app'
  dependsOn: [subnetWeb]
  properties: {
    addressPrefix: '10.0.2.0/24'
    networkSecurityGroup: { id: nsgApp.id }
  }
}

resource subnetData 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: hubVnet
  name: 'snet-data'
  dependsOn: [subnetApp]
  properties: {
    addressPrefix: '10.0.3.0/24'
    networkSecurityGroup: { id: nsgData.id }
  }
}

output nsgWebId  string = nsgWeb.id
output nsgAppId  string = nsgApp.id
output nsgDataId string = nsgData.id
