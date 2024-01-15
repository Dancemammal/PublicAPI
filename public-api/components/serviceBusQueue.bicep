@description('Specifies the Subscription to be used.')
param subscription string

@description('Specifies the location for all resources.')
param location string

@description('Environment Name e.g. dev. Used as a prefix for created resources')
param environment string = 'eespublicapi'

//Specific parameters for the resources
@description('Name of the Service Bus namespace')
param namespaceName string

@description('Name of the Queue')
param queueName string

//Passed in Tags
param tagValues object


// Variables and created data
var serviceBusNamespaceName = '${subscription}-sbns-${environment}-${namespaceName}'
var serviceBusQueueName = '${subscription}-sbq-${environment}-${queueName}'
var serviceBusEndpoint = '${serviceBusNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, serviceBusNamespace.apiVersion).primaryConnectionString


//Resources 

//ServiceBus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
  tags: tagValues
}

//ServiceBus Queue
resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: serviceBusQueueName
  properties: {
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S' //Max time possible to stop messages being auto-deleted
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S' //Max time possible to stop messages being auto-deleted
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableExpress: false
    enablePartitioning: false
    lockDuration: 'PT5M'
    maxDeliveryCount: 10
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
  }
}


//Outputs
output serviceBusQueueRef string = serviceBusQueue.id
output serviceBusQueueName string = serviceBusQueue.name
output serviceBusConnectionString string = serviceBusConnectionString


