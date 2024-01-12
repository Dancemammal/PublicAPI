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

//Resources 

//Registry Seeder
// @description('This module seeds the ACR with the public version of the app')
module acrImport 'br/public:deployment-scripts/import-acr:3.0.1' = if (seedRegistry) {
  name: ContainerImportName
  params: {
    acrName: containerRegistryName
    location: location
    images: array(containerSeedImage)
  }
}
