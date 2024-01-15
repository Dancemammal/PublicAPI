using '../main.bicep'

//Environment Params -------------------------------------------------------------------
param domain = 'publicapi'
param subscription = 's101d01'
param environment = 'api'
param environmentName = 'Development'

//Networking Params --------------------------------------------------------------------------
param deploySubnets = true

//PostgreSQL Database Params -------------------------------------------------------------------
param dbAdministratorLoginName = 'PostgreSQLAdmin'
param dbAdministratorLoginPassword = 'postgreSQLAdminPassword'
param skuName = 'Standard_B1ms'
param storageSizeGB = 32
param autoGrowStatus = 'Disabled'

//Container App Params
param acrHostedImageName = 'hello-world'
param targetPort = 80

//Container Seed Params
param containerSeedImage = 'mcr.microsoft.com/azuredocs/aci-helloworld'
param seedRegistry = true


