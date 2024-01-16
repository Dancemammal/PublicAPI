@description('Specifies the Resource Prefix')
param resourcePrefix string

@description('Specifies the location for all resources.')
param location string

//Specific parameters for the resources
@description('Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Admin Subnet Address Prefix')
param adminSubnetPrefix string = '10.0.0.0/24'

@description('Importer Subnet Address Prefix')
param importerSubnetPrefix string = '10.0.1.0/24'

@description('Publisher Subnet Address Prefix')
param publisherSubnetPrefix string = '10.0.2.0/24'

@description('Content Subnet Address Prefix')
param contentSubnetPrefix string = '10.0.4.0/24'

@description('DataBase Subnet Address Prefix')
param databaseSubnetPrefix string = '10.0.5.0/24'

@description('Deploy the subnets')
param deploySubnets bool = true

//Passed in Tags
param tagValues object

// Variables and created data
var vNetName = '${resourcePrefix}-vnet'
var adminSubnetName = '${resourcePrefix}-snet-admin'
var importerSubnetName = '${resourcePrefix}-snet-importer'
var publisherSubnetName = '${resourcePrefix}-snet-publisher'
var contentSubnetName = '${resourcePrefix}-snet-content'
var dataSubnetName = '${resourcePrefix}-snet-data'


//Resources 
resource virtualnetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = if (deploySubnets) {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
  tags: tagValues
}

resource adminsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = if (deploySubnets) {
  parent: virtualnetwork
  name: adminSubnetName
  properties: {
    addressPrefix: adminSubnetPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
}

resource importersubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = if (deploySubnets) {
  parent: virtualnetwork
  name: importerSubnetName
  properties: {
    addressPrefix: importerSubnetPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
  dependsOn: [
    adminsubnet
  ]
}

resource publishersubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = if (deploySubnets) {
  parent: virtualnetwork
  name: publisherSubnetName
  properties: {
    addressPrefix: publisherSubnetPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
  dependsOn: [
    importersubnet
  ]
}

resource contentsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = if (deploySubnets) {
  parent: virtualnetwork
  name: contentSubnetName
  properties: {
    addressPrefix: contentSubnetPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
  dependsOn: [
    publishersubnet
  ]
}

resource databasesubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = if (deploySubnets) {
  parent: virtualnetwork
  name: dataSubnetName
  properties: {
    addressPrefix: databaseSubnetPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
  dependsOn: [
    contentsubnet
  ]
}

// Outputs for exported use
@description('The fully qualified Azure resource ID of the Network.')
output vNetRef string = resourceId('Microsoft.Network/VirtualNetworks', vNetName)

@description('The fully qualified Azure resource ID of the Subnet.')
output adminSubnetRef string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vNetName, adminSubnetName)

@description('The fully qualified Azure resource ID of the Subnet.')
output importerSubnetRef string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vNetName, importerSubnetName)

@description('The fully qualified Azure resource ID of the Subnet.')
output publisherSubnetRef string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vNetName, publisherSubnetName)

@description('The fully qualified Azure resource ID of the Subnet.')
output databaseSubnetRef string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vNetName, dataSubnetName)
