@description('Specifies the Subscription to be used.')
param subscription string

@description('Specifies the location for all resources.')
param location string

@description('Specifies the Environment for all resources.')
param environment string

//Specific parameters for the resources
@description('Function App Plan : operating system')
@allowed([
  'Windows'
  'Linux'
])
param appServicePlanOS string = 'Linux'

@description('Function App : Runtime Language')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
])
param functionAppRuntime string = 'dotnet'

@description('Specifies the name of the function.')
param functionAppName string = 'processor'

@description('Specifies the name of the Key Vault.')
param keyVaultName string

@description('Database Connection String URI')
@secure()
param databaseConnectionStringURI string

@description('Storage Account Connection String')
param storageAccountConnectionString string

@description('Service Bus Connection String reference')
param serviceBusConnectionString string

//Passed in Tags
param tagValues object


// Variables and created data
var functionName = '${subscription}-${environment}-fa-${functionAppName}'
var appServicePlanName = '${subscription}-${environment}-aps-${functionAppName}'
var applicationInsightsName ='appInsights-${functionAppName}'

//---------------------------------------------------------------------------------------------------------------
// All resources via modules
//---------------------------------------------------------------------------------------------------------------

//Application Insights Deployment
module applicationInsightsModule '../components/appInsights.bicep' = {
  name: 'appInsightsDeploy-${functionAppName}'
  params: {
    location: location
    appInsightsName: applicationInsightsName
  }
}

//App Service Plan Deployment
module appServicePlan '../components/appServicePlan.bicep' = {
  name: 'servicePlanDeploy-${functionAppName}'
  params: {
    name: appServicePlanName
    location: location
    os: appServicePlanOS
  }
}

//Function App Deployment
module functionAppModule '../components/functionApp.bicep' = {
  name: 'functionAppDeploy-${functionAppName}'
  params: {
    functionAppName: functionName
    location: location
    planId: appServicePlan.outputs.servicePlanId
    tagValues: tagValues
  }
  dependsOn: [
    applicationInsightsModule
    appServicePlan
  ]
}

//Key Vault Access Policy Deployment
module keyVaultAccessPolicy '../components/keyVaultAccessPolicy.bicep' = {
  name: 'keyVaultAccessPolicyDeploy-${functionAppName}'
  params: {
    keyVaultName: keyVaultName
    principalId: functionAppModule.outputs.principalId
    tenantId: functionAppModule.outputs.tenantId
  }
  dependsOn: [
    functionAppModule
  ]
}

//Function App Settings Deployment
module functionAppSettingsModule '../components/functionAppSettings.bicep' = {
  name: 'functionConfDeploy-${functionAppName}'
  params: {
    applicationInsightsKey: applicationInsightsModule.outputs.applicationInsightsKey
    databaseConnectionString: databaseConnectionStringURI
    functionAppName: functionAppModule.outputs.functionAppName
    functionAppRuntime: functionAppRuntime
    storageAccountConnectionString: storageAccountConnectionString
    serviceBusConnectionString: serviceBusConnectionString
  }
  dependsOn: [
    functionAppModule
  ]
}
