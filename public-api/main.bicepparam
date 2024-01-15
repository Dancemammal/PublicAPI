using './main.bicep'

//Environment Params -------------------------------------------------------------------
@description('Base domain name for Public API')
param domain = 'publicapi'

@description('Subscription Name e.g. s101d01. Used as a prefix for created resources')
param subscription = 's101d01'

@description('Environment Name e.g. api. Used as a prefix for created resources')
param environment = 'api'

//Networking Params --------------------------------------------------------------------------
@description('Networking : Deploy subnets for networking')
param deploySubnets = true

@description('Networking : Included whitelist')
param storageFirewallRules = ['0.0.0.0/0']

//Storage Params ------------------------------------------------------------------------------
@description('Storage : Name of the root fileshare folder name')
@minLength(3)
@maxLength(63)
param fileShareName = 'data'

@description('Storage : Type of the file share quota')
param fileShareQuota = 1

//PostgreSQL Database Params -------------------------------------------------------------------
@description('Database : administrator login name')
@minLength(1)
param dbAdministratorLoginName = 'PostgreSQLAdmin'

@description('Database : administrator password')
@minLength(8)
@secure()
param dbAdministratorLoginPassword = 'postgreSQLAdminPassword'

@description('Database : Azure Database for PostgreSQL sku name ')
@allowed([
  'Standard_B1ms'
  'Standard_D4ads_v5'
  'Standard_E4ads_v5'
])
param skuName = 'Standard_B1ms'

@description('Database : Azure Database for PostgreSQL Storage Size in GB')
param storageSizeGB = 32

@description('Database : Azure Database for PostgreSQL Autogrow setting')
param autoGrowStatus = 'Disabled'

//Container Registry Params ----------------------------------------------------------------
@minLength(5)
@maxLength(50)
@description('Registry : Name of the azure container registry (must be globally unique)')
param containerRegistryName = 'eesapiacr'

//Container App Params
@description('Container App : Specifies the container image to deploy from the registry <name>:<tag>.')
param acrHostedImageName = 'aci-helloworld'

@description('Specifies the container port.')
param targetPort = 80

@description('Container App : Specifies the container image to seed to the ACR.')
param containerSeedImage = 'mcr.microsoft.com/azuredocs/aci-helloworld'

@description('Select if you want to seed the ACR with a base image.')
param seedRegistry = true

//ServiceBus Queue Params -------------------------------------------------------------------
@description('Name of the Service Bus namespace')
param namespaceName = 'etlnamespace'

@description('Name of the Queue')
param queueName = 'etlfunctionqueue'


