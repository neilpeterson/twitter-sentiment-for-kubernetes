param environment_name string = resourceGroup().name
param location string = resourceGroup().location

@secure()
param SERVICE_BUS_CONNECTION_STR string

@secure()
param SERVICE_BUS_QUEUE_NAME string = 'twitter'

@secure()
param TWITTER_CONSUMER_KEY string

@secure()
param TWITTER_CONSUMER_SECRET string

@secure()
param TWITTER_ACCESS_TOKEN string

@secure()
param TWITTER_ACCESS_TOKEN_SECRET string

@secure()
param AZURE_ANALYTICS_URI string

@secure()
param AZURE_ANALYTICS_KEY string

@secure()
param COSMOS_DB_ENDPOINT string

@secure()
param COSMOS_DB_MASTERKEY string

var logAnalyticsWorkspaceName = 'logs-${environment_name}'
var appInsightsName = 'appins-${environment_name}'

resource logAnalyticsWorkspace'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environment_name
  location: location
  properties: {
    daprAIInstrumentationKey: reference(appInsights.id, '2020-02-02').InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspace.id, '2021-06-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspace.id, '2021-06-01').primarySharedKey
      }
    }
  }
}

resource processtweets 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'processtweets'
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      secrets: [
        {
          name: 'service-bus-connection-str'
          value: SERVICE_BUS_CONNECTION_STR
          
        }
        {
          name: 'service-bus-queue-name'
          value: SERVICE_BUS_QUEUE_NAME
        }
        {
          name: 'azure-analytics-uri'
          value: AZURE_ANALYTICS_URI
        }
        {
          name: 'azure-analytics-key'
          value: AZURE_ANALYTICS_KEY
        }
        {
          name: 'cosmos-db-endpoint'
          value: COSMOS_DB_ENDPOINT
        }
        {
          name: 'cosmos-db-masterkey'
          value: COSMOS_DB_MASTERKEY
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'docker.io/neilpeterson/process-tweet-sp:v2.0'
          name: 'process-tweet-sb'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'SERVICE_BUS_CONNECTION_STR'
              secretRef: 'service-bus-connection-str'
            }
            {
              name: 'SERVICE_BUS_QUEUE_NAME'
              secretRef: 'service-bus-queue-name'
            }
            {
              name: 'AZURE_ANALYTICS_URI'
              secretRef: 'azure-analytics-uri'
            }
            {
              name: 'AZURE_ANALYTICS_KEY'
              secretRef: 'azure-analytics-key'
            }
            {
              name: 'COSMOS_DB_ENDPOINT'
              secretRef: 'cosmos-db-endpoint'
            }
            {
              name: 'COSMOS_DB_MASTERKEY'
              secretRef: 'cosmos-db-masterkey'
            }
            {
              name: 'COSMOS_DB_DATABASE'
              value: 'twitter'
            }
            {
              name: 'COSMOS_DB_COLLECTION'
              value: 'twitter'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 2
        maxReplicas: 10
        rules: [
          {
            name: 'queue-length'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                queueName: 'twitter'
                messageCount: '20'
              }
              auth: [
                {
                  secretRef: 'service-bus-connection-str'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}

resource gettweet 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'gettweet'
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      secrets: [
        {
          name: 'service-bus-connection-str'
          value: SERVICE_BUS_CONNECTION_STR
          
        }
        {
          name: 'service-bus-queue-name'
          value: SERVICE_BUS_QUEUE_NAME
        }
        {
          name: 'twitter-consumer-key'
          value: TWITTER_CONSUMER_KEY
        }
        {
          name: 'twitter-consumer-secret'
          value: TWITTER_CONSUMER_SECRET
        }
        {
          name: 'twitter-access-token'
          value: TWITTER_ACCESS_TOKEN
        }
        {
          name: 'twitter-access-token-secret'
          value: TWITTER_ACCESS_TOKEN_SECRET
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'docker.io/neilpeterson/get-tweet-sb:v1.0'
          name: 'get-tweet-sb'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'SERVICE_BUS_CONNECTION_STR'
              secretRef: 'service-bus-connection-str'
            }
            {
              name: 'SERVICE_BUS_QUEUE_NAME'
              secretRef: 'service-bus-queue-name'
            }
            {
              name: 'TWITTER_CONSUMER_KEY'
              secretRef: 'twitter-consumer-key'
            }
            {
              name: 'TWITTER_CONSUMER_SECRET'
              secretRef: 'twitter-consumer-secret'
            }
            {
              name: 'TWITTER_ACCESS_TOKEN'
              secretRef: 'twitter-access-token'
            }
            {
              name: 'TWITTER_ACCESS_TOKEN_SECRET'
              secretRef: 'twitter-access-token-secret'
            }
            {
              name: 'TWITTER_TEXT'
              value: 'Sammamish'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    }
  }
}

resource charttweet 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'charttweet'
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      ingress: {
        external: true
        allowInsecure: true
        targetPort: 80
      }
      secrets: [
        {
          name: 'cosmos-db-endpoint'
          value: COSMOS_DB_ENDPOINT
        }
        {
          name: 'cosmos-db-masterkey'
          value: COSMOS_DB_MASTERKEY
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'docker.io/neilpeterson/sb-chart-tweet:v1.0'
          name: 'get-tweet-sb'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'COSMOS_DB_ENDPOINT'
              secretRef: 'cosmos-db-endpoint'
            }
            {
              name: 'COSMOS_DB_MASTERKEY'
              secretRef: 'cosmos-db-masterkey'
            }
            {
              name: 'COSMOS_DB_DATABASE'
              value: 'twitter'
            }
            {
              name: 'COSMOS_DB_COLLECTION'
              value: 'twitter'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    }
  }
}

