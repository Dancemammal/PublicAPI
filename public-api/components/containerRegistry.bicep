@description('Specifies the Subscription to be used.')
param subscription string

@description('Specifies the location for all resources.')
param location string

@minLength(5)
@maxLength(50)
@description('Name of the azure container registry (must be globally unique)')
param containerRegistryName string = 'eesapiacr'

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param containerRegistrySku string = 'Basic'

//Passed in Tags
param tagValues object

//Variables
var ContainerRegistryName = '${subscription}${containerRegistryName}'


//Resources 
resource apiContainerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: ContainerRegistryName
  location: location
  sku: {
    name: containerRegistrySku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    policies: {
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
    }
  }
  tags: tagValues
}




// Outputs for exported use
output crID string = apiContainerRegistry.id
output crName string = apiContainerRegistry.name
output crLoginServer string = apiContainerRegistry.properties.loginServer
