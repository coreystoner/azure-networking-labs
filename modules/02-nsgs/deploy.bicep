// =============================================================================
// Module 02: Network Security Groups
// Azure Networking Labs
// =============================================================================
//
// This template adds NSGs to the hub VNet subnets from Module 01.
// Each subnet tier gets its own NSG with rules appropriate to its function:
//
//   snet-web  →  nsg-web   : Allow HTTP/HTTPS from Internet
//   snet-app  →  nsg-app   : Allow traffic from snet-web only
//   snet-data →  nsg-data  : Allow traffic from snet-app only
//
// This creates a defence-in-depth tiered model where each layer can only
// communicate with the adjacent tier.
//
// Prerequisite: Module 01 (vnet-hub) must be deployed.
// Cost: $0.00/hr  — NSGs are free in Azure.
// =============================================================================

@description('Azure region. Defaults to resource group location.')
param location string = resourceGroup().location

// Reference the existing hub VNet from Module 01
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
}

// ---------------------------------------------------------------------------
// NSG: Web Tier
// Allow HTTP and HTTPS inbound from the internet.
// ---------------------------------------------------------------------------
resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-web'
  location: location
  tags: { lab: 'azure-networking-labs', module: '02-nsgs' }
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
          description: 'Allow HTTP traffic from the internet'
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
          description: 'Allow HTTPS traffic from the internet'
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// NSG: App Tier
// Allow traffic only from the web subnet (10.0.1.0/24).
// Nothing else should reach the app tier directly.
// ---------------------------------------------------------------------------
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
          description: 'Allow all traffic from the web subnet'
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
          description: 'Explicitly deny everything not whitelisted above'
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// NSG: Data Tier
// Allow traffic only from the app subnet (10.0.2.0/24).
// ---------------------------------------------------------------------------
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
          description: 'Allow all traffic from the app subnet'
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
          description: 'Explicitly deny everything not whitelisted above'
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Associate NSGs with subnets
// Using child resource syntax to update existing subnets.
// ---------------------------------------------------------------------------
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
  dependsOn: [subnetWeb] // Update subnets sequentially to avoid conflicts
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

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output nsgWebId  string = nsgWeb.id
output nsgAppId  string = nsgApp.id
output nsgDataId string = nsgData.id
