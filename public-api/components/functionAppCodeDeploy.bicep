@description('Specifies the Resource Prefix')
param resourcePrefix string

//Specific parameters for the resources
@description('The name of the function app you wish to add the code to.')
param functionAppName string

@description('The function app zip content url.')
param packageUri string

// Variables and created data
var functionName = '${resourcePrefix}-fa-${functionAppName}'

//Resources
resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${functionName}/ZipDeploy'
  properties: {
    packageUri: packageUri
  }
}
