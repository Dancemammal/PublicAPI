@description('Specifies the Subscription to be used.')
param subscription string

@description('Specifies the location for all resources.')
param location string

//Specific parameters for the resources
@description('Name of the Service Bus namespace')
param namespaceName string

@description('Name of the Queue')
param queueName string

//Passed in Tags
param tagValues object


// Variables and created data
var serviceBusNamespaceName = '${subscription}-sbns-${namespaceName}'
var serviceBusQueueName = '${subscription}-sbq-${queueName}'
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
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
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
output ServiceBusQueueRef string = serviceBusQueue.id
output ServiceBusQueueName string = serviceBusQueue.name
output ServiceBusConnectionString string = serviceBusConnectionString


