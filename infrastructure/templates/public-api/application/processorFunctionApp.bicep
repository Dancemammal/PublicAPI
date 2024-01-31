@description('Specifies the Resource Prefix')
param resourcePrefix string

@description('Specifies the location for all resources.')
param location string

//Specific parameters for the resources
@description('Function App : Runtime Language')
param functionAppRuntime string = 'dotnet'

@description('Specifies the name of the function.')
param functionAppName string = 'publicapi-processor'

@description('Storage Account connection string')
@secure()
param storageAccountConnectionString string

@description('Specifies the additional setting to add to the functionapp.')
param settings object

//Passed in Tags
param tagValues object


// Variables and created data


//---------------------------------------------------------------------------------------------------------------
// All resources via modules
//---------------------------------------------------------------------------------------------------------------

//Function App Deployment
module functionAppModule '../components/functionApp.bicep' = {
  name: '${resourcePrefix}-${functionAppName}'
  params: {
    resourcePrefix: resourcePrefix
    functionAppName: functionAppName
    storageAccountConnectionString: storageAccountConnectionString
    location: location
    tagValues: tagValues
    settings: settings
    functionAppRuntime: functionAppRuntime
  }
}

//Key Vault Access Policy Deployment
module keyVaultAccessPolicy '../components/keyVaultAccessPolicy.bicep' = {
  name: 'keyVaultAccessPolicyDeploy-${functionAppName}'
  params: {
    keyVaultName: settings.keyVaultName
    principalId: functionAppModule.outputs.principalId
    tenantId: functionAppModule.outputs.tenantId
  }
  dependsOn: [
    functionAppModule
  ]
}

