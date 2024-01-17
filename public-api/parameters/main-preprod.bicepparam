using '../main.bicep'

//Environment Params -------------------------------------------------------------------
param domain = 'publicapi'
param subscription = 's101d01'
param environment = 'eespubapi'
param environmentName = 'Pre-Prod'

//Networking Params --------------------------------------------------------------------------
param deploySubnets = true

//PostgreSQL Database Params -------------------------------------------------------------------
param postgreSQLserverName = 'metadata'
param dbAdminName = 'PostgreSQLAdmin'
param dbAdminPassword = 'postgreSQLAdminPassword'
param dbSkuName = 'Standard_B1ms'
param storageSizeGB = 32
param autoGrowStatus = 'Disabled'

//Container Registry
param containerRegistryName = 'eesapiacr'
param deployRegistry = true

//Container App Params
param containerAppName = 'pubapi'
param acrHostedImageName = 'azuredocs/aci-helloworld'
param targetPort = 80

//Container Seed Params
param containerSeedImage = 'mcr.microsoft.com/azuredocs/aci-helloworld'
param seedRegistry = true
