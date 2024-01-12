@description('Specifies the Subscription to be used.')
param subscription string

@description('Specifies the location for all resources.')
param location string

@description('Select if you want to seed the ACR with a base image.')
param seedRegistry bool = true

@minLength(5)
@maxLength(50)
@description('Name of the azure container registry (must be globally unique)')
param containerRegistryName string = 'eesapiacr'

@description('Specifies the base docker container image to deploy.')
param containerSeedImage string = 'mcr.microsoft.com/mcr/hello-world'

//Variables 
var ContainerImportName = '${subscription}importContainerImage'
var UserIdentityName = '${subscription}-id-seeder'
var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

//Resources 

//Managed Identity
resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: UserIdentityName
  location: location
}

@description('This allows the managed identity of the seeder to access the registry, note scope is applied to the wider ResourceGroup not the ACR')
resource uaiRbacPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uai.id, acrPullRole)
  properties: {
    roleDefinitionId: acrPullRole
    principalId: uai.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

//Registry Seeder
@description('This module seeds the ACR with the public version of the app')
module acrImportImage 'br/public:deployment-scripts/import-acr:3.0.1' = if (seedRegistry) {
  name: ContainerImportName
  params: {
    useExistingManagedIdentity: false
    managedIdentityName: uai.name
    existingManagedIdentityResourceGroupName: resourceGroup().name
    existingManagedIdentitySubId: az.subscription().subscriptionId
    acrName: containerRegistryName
    location: location
    images: array(containerSeedImage)
  }
}
