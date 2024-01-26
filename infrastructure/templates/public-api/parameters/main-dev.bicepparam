using '../main.bicep'

//Environment Params -------------------------------------------------------------------
param domain = 'publicapi'
param subscription = 's101'
param environmentName = 'Development'

//Networking Params --------------------------------------------------------------------------
param deploySubnets = true

//PostgreSQL Database Params -------------------------------------------------------------------
param dbAdminName = 'PostgreSQLAdmin'
param dbAdminPassword = 'postgreSQLAdminPassword'
param dbSkuName = 'Standard_B1ms'
param storageSizeGB = 32
param autoGrowStatus = 'Disabled'

//Container Registry -------------------------------------------------------------------
param containerRegistryName = 'eesapiacr'
param deployRegistry = true

//Container App Params -------------------------------------------------------------------
param containerAppName = 'eesapi'
param acrHostedImageName = 'azuredocs/aci-helloworld'
param targetPort = 80
param useDummyImage = true
