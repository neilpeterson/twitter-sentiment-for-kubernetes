# Standard Deployment

## Azure Infrastructure

1. Gather Twitter API Keys and secrets.
2. Deploy Azure Infrastructure. During this process, enter Twitter API keys and secrets.

```
az group create --name twitter-showtime-001 --location eastus  
az deployment group create --template-file ./deployment/bicep/azure-infra/main.bicep --resource-group twitter-showtime-001
```

## Local Execution

Create the following environment variables for consumption by the applications.

```
$env:TWITTER_CONSUMER_KEY = ""
$env:TWITTER_CONSUMER_SECRET = ""
$env:TWITTER_ACCESS_TOKEN = ""
$env:TWITTER_ACCESS_TOKEN_SECRET = ""
$env:AZURE_ANALYTICS_URI = ""
$env:AZURE_ANALYTICS_KEY = ""
$env:COSMOS_DB_ENDPOINT = ""
$env:COSMOS_DB_MASTERKEY = ""
$env:COSMOS_DB_DATABASE = "twitter"
$env:COSMOS_DB_COLLECTION = "twitter"
$env:SERVICE_BUS_CONNECTION_STR = ""
$env:SERVICE_BUS_QUEUE_NAME = ""
$env:TWITTER_TEXT = "Seattle"
```

CONNECTION_STR = os.environ['SERVICE_BUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICE_BUS_QUEUE_NAME"]

Activeate Python virtual environment

```
/Users/neilpeterson/Documents/code/python-virtual-env/twitter-sentiment/bin/Activate.ps1
```

## Azure Container Apps Deployment

```
az deployment group create --template-file ./deployment/bicep/container-apps/main.bicep --parameters ./deployment/bicep/container-apps/main.json --resource-group sat-twitter-001
```

