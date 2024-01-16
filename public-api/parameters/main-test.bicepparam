using '../main.bicep'

//Environment Params -------------------------------------------------------------------
param domain = 'publicapi'
param subscription = 's101d01'
param environment = 'api'
param environmentName = 'Test'

//Networking Params --------------------------------------------------------------------------
param deploySubnets = true

//PostgreSQL Database Params -------------------------------------------------------------------
param postgreSQLserverName = 'metadata'
param dbAdminName = 'PostgreSQLAdmin'
param dbAdminPassword = 'postgreSQLAdminPassword'
param dbSkuName = 'Standard_B1ms'
param storageSizeGB = 32
param autoGrowStatus = 'Disabled'

// Variables and created data
param containerRegistryName = 'eesapiacr'

//Container App Params
param containerAppName = 'publicapi'
param acrHostedImageName = 'azuredocs/aci-helloworld'
param targetPort = 80

//Container Seed Params
param containerSeedImage = 'mcr.microsoft.com/azuredocs/aci-helloworld'
param seedRegistry = true
