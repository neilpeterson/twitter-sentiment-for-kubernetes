// @minLength(1)
// @maxLength(63)
// param aksName string

@minLength(2)
@maxLength(64)
param cognitiveName string

@minLength(3)
@maxLength(44)
param cosmosName string

@minLength(3)
@maxLength(24)
param storageAccountName string

// optional params
// param aksVersion string = '1.16.9'
param location string = resourceGroup().location

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
  }
}

resource storagequeue 'Microsoft.Storage/storageAccounts/queueServices@2021-02-01' = {
    name: 'default'
    parent: storageaccount
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-02-01' = {
    name: storageAccountName
    parent: storagequeue
}

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

resource analytics 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
    name: cognitiveName
    location: location
    sku: {
        name: 'S'
    }
    kind: 'TextAnalytics'
    properties: {
        publicNetworkAccess: 'Enabled'
    }
}
