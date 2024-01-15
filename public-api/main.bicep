//Environment Params -------------------------------------------------------------------
@description('Base domain name for Public API')
param domain string

@description('Subscription Name e.g. s101d01. Used as a prefix for created resources')
param subscription string = 's101d01'

@description('Environment Name Used as a prefix for created resources')
param environment string = 'eespublicapi'

@description('Specifies the location in which the Azure resources should be deployed.')
param location string = resourceGroup().location

//Tagging Params ------------------------------------------------------------------------
param environmentName string = 'Development'

param tagValues object = {
  departmentName: 'Unknown'
  environmentName: environmentName
  solutionName: 'API'
  subscriptionName: 'Unknown'
  costCentre: 'Unknown'
  serviceOwnerName: 'Unknown'
  dateProvisioned: utcNow('u')
  createdBy: 'Unknown'
  deploymentRepo: 'N/A'
  deploymentScript: 'main.bicep'
}

//Networking Params --------------------------------------------------------------------------
@description('Networking : Deploy subnets for networking')
param deploySubnets bool = true

@description('Networking : Included whitelist')
param storageFirewallRules array = ['0.0.0.0/0']

//Storage Params ------------------------------------------------------------------------------
@description('Storage Account Name')
param storageAccountName string = 'core'

@description('Storage : Name of the root fileshare folder name')
@minLength(3)
@maxLength(63)
param fileShareName string = 'data'

@description('Storage : Type of the file share quota')
param fileShareQuota int = 1

//PostgreSQL Database Params -------------------------------------------------------------------
@description('Database : PostgreSQL server Name')
param postgreSQLserverName string

@description('Database : administrator login name')
@minLength(0)
param dbAdminName string

@description('Database : administrator password')
@minLength(8)
@secure()
param dbAdminPassword string

@description('Database : Azure Database for PostgreSQL sku name ')
@allowed([
  'Standard_B1ms'
  'Standard_D4ads_v5'
  'Standard_E4ads_v5'
])
param dbSkuName string = 'Standard_B1ms'

@description('Database : Azure Database for PostgreSQL Storage Size in GB')
param storageSizeGB int = 32

@description('Database : Azure Database for PostgreSQL Autogrow setting')
param autoGrowStatus string = 'Disabled'

//Container Registry Params ----------------------------------------------------------------
@minLength(5)
@maxLength(50)
@description('Registry : Name of the azure container registry (must be globally unique)')
param containerRegistryName string

//Container App Params
@minLength(2)
@maxLength(32)
@description('Specifies the name of the container app.')
param containerAppName string

@description('Specifies the name of the container app environment.')
param containerAppEnvName string = 'publicAPI'

@description('Specifies the name of the log analytics workspace.')
param containerAppLogAnalyticsName string = 'publicAPI'

@description('Container App : Specifies the container image to deploy from the registry <name>:<tag>.')
param acrHostedImageName string

@description('Specifies the container port.')
param targetPort int = 80

@description('Container App : Specifies the container image to seed to the ACR.')
param containerSeedImage string

@description('Select if you want to seed the ACR with a base image.')
param seedRegistry bool = true

//ServiceBus Queue Params -------------------------------------------------------------------
@description('Name of the Service Bus namespace')
param namespaceName string = 'processornamespace'

@description('Name of the Queue')
param queueName string = 'Processorfunctionqueue'

//ETL Function Paramenters ------------------------------------------------------------------
@description('Specifies the name of the function.')
param functionAppName string = 'processor'

//---------------------------------------------------------------------------------------------------------------
// All resources via modules
//---------------------------------------------------------------------------------------------------------------

//Deploy Networking
module vnetModule 'components/network.bicep' = {
  name: 'virtualNetworkDeploy'
  params: {
    subscription: subscription
    location: location
    environment: environment
    deploySubnets: deploySubnets
    tagValues: tagValues
  }
}

//Deploy Storage Account
module storageAccountModule 'components/storageAccount.bicep' = {
  name: 'storageAccountDeploy'
  params: {
    subscription: subscription
    location: location
    storageAccountName: storageAccountName
    storageSubnetRules: [vnetModule.outputs.adminSubnetRef, vnetModule.outputs.importerSubnetRef, vnetModule.outputs.publisherSubnetRef]
    storageFirewallRules: storageFirewallRules
    tagValues: tagValues
  }
  dependsOn: [
    vnetModule
  ]
}

//Deploy File Share
module fileShareModule 'components/fileShares.bicep' = {
  name: 'fileShareDeploy'
  params: {
    fileShareName: fileShareName
    fileShareQuota: fileShareQuota
    storageAccountName: storageAccountModule.outputs.storageAccountName
    //tags
  }
  dependsOn: [
    storageAccountModule
  ]
}

//Deploy Function blob store
module blobStoreModule 'components/blobStore.bicep' = {
  name: 'blobStoreDeploy'
  params: {
    storageAccountName: storageAccountModule.outputs.storageAccountName
    //tags
  }
  dependsOn: [
    storageAccountModule
  ]
}

//Deploy Key Vault
module keyVaultModule 'components/keyVault.bicep' = {
  name: 'keyVaultDeploy'
  params: {
    subscription: subscription
    location: location
    environment: environment
    tenantId: az.subscription().tenantId
    tagValues: tagValues
  }
}

//Deploy PostgreSQL Database
module databaseModule 'components/postgresqlDatabase.bicep' = {
  name: 'postgreSQLDatabaseDeploy'
  params: {
    subscription: subscription
    location: location
    environment: environment
    serverName: postgreSQLserverName
    adminName: dbAdminName
    adminPassword: dbAdminPassword
    dbSkuName: dbSkuName
    storageSizeGB: storageSizeGB
    autoGrowStatus: autoGrowStatus
    keyVaultName: keyVaultModule.outputs.keyVaultName
    tagValues: tagValues
  }
  dependsOn: [
    vnetModule
    keyVaultModule
  ]
}

//Deploy Container Registry 
module containerRegistryModule 'components/containerRegistry.bicep' = {
  name: 'acrDeploy'
  params: {
    subscription: subscription
    location: location
    containerRegistryName: containerRegistryName
    tagValues: tagValues
  }
}

//Seed Container Registry 
module seedRegistryModule 'components/acrSeeder.bicep' = {
  name: 'acrSeeder'
  params: {
    subscription: subscription
    location: location
    containerRegistryName: containerRegistryModule.outputs.containerRegistryName
    containerSeedImage: containerSeedImage // seeder image name 'mcr.microsoft.com/azuredocs/aci-helloworld'
    seedRegistry: seedRegistry
  }
  dependsOn: [
    containerRegistryModule
    keyVaultModule
  ]
}

//Deploy Container Application
module containerAppModule 'components/containerApp.bicep' = {
  name: 'appContainerDeploy'
  params: {
    subscription: subscription
    location: location
    environment: environment
    containerAppName: containerAppName
    containerAppEnvName: containerAppEnvName
    containerAppLogAnalyticsName: containerAppLogAnalyticsName
    acrLoginServer: containerRegistryModule.outputs.containerRegistryLoginServer
    acrHostedImageName: acrHostedImageName //image name plus tag i.e. 'azuredocs/aci-helloworld'
    targetPort: targetPort
    envParams: [
      {
        name: 'adoDBConnectionString'
        value: databaseModule.outputs.dbConnectionString
      }
      {
        name: 'serviceBusConnectionString'
        value: serviceBusFunctionQueueModule.outputs.serviceBusConnectionString
      }
    ]
    tagValues: tagValues
  }
}

//Deploy Service Bus
module serviceBusFunctionQueueModule 'components/serviceBusQueue.bicep' = {
  name: 'serviceBusQueueDeploy'
  params: {
    subscription: subscription
    location: location
    namespaceName: namespaceName
    queueName:queueName
    tagValues: tagValues
  }
}

//Deploy ETL Function
module etlFunctionAppModule 'application/etlFunctionApp.bicep' = {
  name: 'etlFunctionAppDeploy'
  params: {
    subscription: subscription
    location: location
    environment: environment
    functionAppName: functionAppName
    keyVaultName: keyVaultModule.outputs.keyVaultName
    databaseConnectionStringURI: databaseModule.outputs.connectionStringSecretUri
    storageAccountConnectionString: storageAccountModule.outputs.storageAccountConnectionString
    serviceBusConnectionString: serviceBusFunctionQueueModule.outputs.serviceBusConnectionString
    tagValues: tagValues
  }
  dependsOn: [
    serviceBusFunctionQueueModule
    keyVaultModule
  ]
}


//outputs
output containerRegistryLoginServer string = containerRegistryModule.outputs.containerRegistryLoginServer
output containerRegistryName string = containerRegistryModule.name
output metadataDatabaseRef string = databaseModule.outputs.databaseRef
