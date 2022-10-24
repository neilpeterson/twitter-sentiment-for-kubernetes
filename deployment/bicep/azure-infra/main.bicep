param cognitiveName string = resourceGroup().name
param cosmosName string = resourceGroup().name
param kayVaultName string = resourceGroup().name
param serviceBusName string = resourceGroup().name
param serviceBusQueueName string = 'twitter'
param location string = resourceGroup().location

@secure()
param TWITTERCONSUMERKEY string

@secure()
param TWITTERCONSUMERSECRET string

@secure()
param TWITTERACCESSTOKEN string

@secure()
param TWITTERACCESSTOKENSECRET string

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
    name: cosmosName
    location: location
    properties: {
        databaseAccountOfferType: 'Standard'
        locations: [
            {
                locationName: location
            }
        ]
    }
}

resource analytics 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
    name: cognitiveName
    location: location
    sku: {
        name: 'S0'
    }
    kind: 'CognitiveServices'
    identity: {
        type: 'None'
    }
}

resource servicebus 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusName
  location: location
  sku: {
    name: 'Standard'
  }
}

resource servicebusqueue 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  name: serviceBusQueueName
  parent: servicebus
}

resource servicebusaccess 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' = {
  name: serviceBusQueueName
  parent: servicebus
  properties: {
    rights: [
      'send'
      'listen'
    ]
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kayVaultName
  location: location
  properties: {
    enabledForTemplateDeployment: true
    tenantId: tenant().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  accessPolicies: []
  }
}

resource servicebusqueuename 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'SERVICEBUSQUEUENAME'
  properties: {
    value: serviceBusQueueName
  }
}

resource servicebusconnectionstring 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'SERVICEBUSCONNECTIONSTR'
  properties: {
    value: servicebusaccess.listKeys().primaryConnectionString
  }
}

resource accesstoken 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if (!empty(TWITTERACCESSTOKEN)) {
  parent: keyvault
  name: 'TWITTERACCESSTOKEN'
  properties: {
    value: TWITTERACCESSTOKEN
  }
}

resource accesstokensecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if (!empty(TWITTERACCESSTOKENSECRET)) {
  parent: keyvault
  name: 'TWITTERACCESSTOKENSECRET'
  properties: {
    value: TWITTERACCESSTOKENSECRET
  }
}

resource consumerkey 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if (!empty(TWITTERCONSUMERKEY)) {
  parent: keyvault
  name: 'TWITTERCONSUMERKEY'
  properties: {
    value: TWITTERCONSUMERKEY
  }
}

resource consumersecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if (!empty(TWITTERCONSUMERSECRET)) {
  parent: keyvault
  name: 'TWITTERCONSUMERSECRET'
  properties: {
    value: TWITTERCONSUMERSECRET
  }
}

resource azureanalyticsuri 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'AZUREANALYTICSURI'
  properties: {
    value: analytics.properties.endpoint
  }
}

resource azureanalyticskey 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'AZUREANALYTICSKEY'
  properties: {
    value: analytics.listKeys().key1
  }
}

resource cosmosdbendpoint 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'COSMOSDBENDPOINT'
  properties: {
    value: cosmosdb.properties.documentEndpoint
  }
}

resource cosmosdbmasterkey 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'COSMOSDBMASTERKEY'
  properties: {
    value: cosmosdb.listKeys().primaryMasterKey
  }
}

resource cosmosdbdatabase 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'COSMOSDBDATABASE'
  properties: {
    value: 'twitter'
  }
}

resource cosmosdbcollection 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: 'COSMOSDBCOLLECTION'
  properties: {
    value: 'twitter'
  }
}


