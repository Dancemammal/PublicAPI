@description('Specifies the location for all resources.')
param location string

//Specific parameters for the resources
@description('Function App name')
param functionAppName string

@description('App Service Plan Id')
param planId string

//Passed in Tags
param tagValues object

// Variables and created data
var kind = 'functionapp'


//Resources
resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: kind
  properties: {
    serverFarmId: planId
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tagValues
}


//Output
output functionAppName string = functionApp.name
output principalId string = functionApp.identity.principalId
output tenantId string = functionApp.identity.tenantId
