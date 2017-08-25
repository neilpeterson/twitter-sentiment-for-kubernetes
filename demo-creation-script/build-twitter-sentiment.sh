# Twitter API Endpoint and Credentials - this is not automated so must be specified.
TWITTER_CONSUMER_KEY=ROgy0lRckDNDXfRtkYYefr7TT
TWITTER_CONSUMER_SECRET=iLT0fQV0vw3orRbDGqCwXj2aHJoygOr0Yxw7XrBBJOEf81lyLv
TWITTER_ACCESS_TOKEN=556115100-IYoAeEAVj2oFqKeLA3QmQyLs8VPft9AC8NS4TV0Q
TWITTER_ACCESS_TOKEN_SECRET=ohAOB5kDgXJ6sIfEt3UyWnpUq6y9VbRcGQU4OOiPnGAIP

# Twitter search term - used to filter returned tweets.
TWITTER_TEXT=Seattle

# Names for the Azure Resource Group, Storage Account, and Cosmos DB name.
AZURE_RESOURCE_GROUP=mytwittersentiment
AZURE_STORAGE_ACCT=mytwittersentiment
AZURE_COSMOS_DB=mytwittersentiment
AZURE_ANALYTICS=mytwittersentiment

# Create resource group
az group create --name $AZURE_RESOURCE_GROUP --location eastus

# Create storage account
az storage account create --name $AZURE_STORAGE_ACCT --resource-group $AZURE_RESOURCE_GROUP --sku Standard_LRS

# Create storage queue
az storage queue create --name $AZURE_STORAGE_ACCT --account-name $AZURE_STORAGE_ACCT 

# Create Comsmos DB
az cosmosdb create --name $AZURE_COSMOS_DB --resource-group $AZURE_RESOURCE_GROUP

# Create Congnitive Services API
az group deployment create --name $AZURE_ANALYTICS --resource-group $AZURE_RESOURCE_GROUP --template-file azuredeploy.json --parameters text_sentiment_api=$AZURE_ANALYTICS

# # Get endpoints and keys
AZURE_QUEUE_KEY=$(az storage account keys list --account-name $AZURE_STORAGE_ACCT --resource-group $AZURE_RESOURCE_GROUP --query [0].value -o tsv)
COSMOS_DB_ENDPOINT=$(az cosmosdb show --name $AZURE_COSMOS_DB --resource-group $AZURE_RESOURCE_GROUP --query documentEndpoint -o tsv)
COSMOS_DB_MASTERKEY=$(az cosmosdb list-keys --name $AZURE_COSMOS_DB --resource-group $AZURE_RESOURCE_GROUP --query primaryMasterKey -o tsv)
AZURE_ANALYTICS_ENDPOINT=$(az cognitiveservices account show --resource-group $AZURE_RESOURCE_GROUP --name $AZURE_ANALYTICS --query endpoint -o tsv)/sentiment
AZURE_ANALYTICS_KEY=$(az cognitiveservices account keys list --resource-group $AZURE_RESOURCE_GROUP --name $AZURE_ANALYTICS --query key1 -o tsv)

# Create YAML
cat <<EOF > twitter-sentiment.yml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: process-tweet
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: process-tweet
    spec:
      containers:
      - name: process-tweet
        image: neilpeterson/process-tweet-log
        env:
        - name: AZURE_ANALYTICS_URI
          value: $AZURE_ANALYTICS_ENDPOINT
        - name: AZURE_ANALYTICS_KEY
          value: $AZURE_ANALYTICS_KEY
        - name: AZURE_STORAGE_ACCT
          value: $AZURE_STORAGE_ACCT
        - name: AZURE_QUEUE
          value: $AZURE_STORAGE_ACCT
        - name: AZURE_QUEUE_KEY
          value: $AZURE_QUEUE_KEY
        - name: COSMOS_DB_ENDPOINT
          value: $COSMOS_DB_ENDPOINT
        - name: COSMOS_DB_MASTERKEY
          value: $COSMOS_DB_MASTERKEY
        - name:  COSMOS_DB_DATABASE
          value: $AZURE_COSMOS_DB
        - name:  COSMOS_DB_COLLECTION
          value: $AZURE_COSMOS_DB
      terminationGracePeriodSeconds: 0
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: get-tweet
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: get-tweet
    spec:
      containers:
      - name: get-tweet
        image: neilpeterson/get-tweet
        env:
        - name: AZURE_STORAGE_ACCT
          value: $AZURE_STORAGE_ACCT
        - name: AZURE_QUEUE
          value: $AZURE_STORAGE_ACCT 
        - name: AZURE_QUEUE_KEY
          value: $AZURE_QUEUE_KEY
        - name: TWITTER_CONSUMER_KEY
          value: $TWITTER_CONSUMER_KEY
        - name: TWITTER_CONSUMER_SECRET
          value: $TWITTER_CONSUMER_SECRET
        - name: TWITTER_ACCESS_TOKEN
          value: $TWITTER_ACCESS_TOKEN
        - name: TWITTER_ACCESS_TOKEN_SECRET
          value: $TWITTER_ACCESS_TOKEN_SECRET
        - name: TWITTER_TEXT
          value: $TWITTER_TEXT
      terminationGracePeriodSeconds: 0
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: chart-tweet
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: chart-tweet
    spec:
      containers:
      - name: chart-tweet
        image: neilpeterson/chart-tweet
        env:
        - name: COSMOS_DB_ENDPOINT
          value: $COSMOS_DB_ENDPOINT
        - name: COSMOS_DB_MASTERKEY
          value: $COSMOS_DB_MASTERKEY
        - name:  COSMOS_DB_DATABASE
          value: $AZURE_COSMOS_DB
        - name:  COSMOS_DB_COLLECTION
          value: $AZURE_COSMOS_DB
---
apiVersion: v1
kind: Service
metadata:
  name: chart-tweet
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: chart-tweet
EOF

# Create YAML
cat <<EOF > twitter-sentiment-auto-scale.yml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: azurequeues.apex-sample.com
spec:
  group: apex-sample.com
  version: v1
  scope: Namespaced
  names:
    plural: azurequeues
    singular: azurequeue
    kind: AzureQueue
    shortNames:
    - aq
---
apiVersion: "apex-sample.com/v1"
kind: AzureQueue
metadata:
  name: process-tweet
spec:
  AZURESTORAGEACCT: $AZURE_STORAGE_ACCT
  AZUREQUEUE: $AZURE_STORAGE_ACCT
  AZUREQUEUEKEY: $AZURE_QUEUE_KEY
  QUEUELENGTH: 10
  MIN_REPLICA: 1
  MAX_REPLICA: 3
  DEPLOYMENTNAME: process-tweet
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: kube-azure-queue-controller
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: kube-azure-queue-controller
    spec:
      containers:
      - name: kubectl-sidecar
        image: neilpeterson/kubectl-proxy-sidecar
      - name: kube-azure-queue-controller
        image: neilpeterson/azure-queue-controller
EOF

# Create environment variables
cat <<EOF > twitter-sentiment-variables.sh
# Azure Analytics
export AZURE_ANALYTICS_URI=$AZURE_ANALYTICS_ENDPOINT
export AZURE_ANALYTICS_KEY=$AZURE_ANALYTICS_KEY

# Azure Storage
export AZURE_STORAGE_ACCT=$AZURE_STORAGE_ACCT
export AZURE_QUEUE=$AZURE_STORAGE_ACCT 
export AZURE_QUEUE_KEY=$AZURE_QUEUE_KEY

# Twitter
export TWITTER_CONSUMER_KEY=$TWITTER_CONSUMER_KEY
export TWITTER_CONSUMER_SECRET=$TWITTER_CONSUMER_SECRET
export TWITTER_ACCESS_TOKEN=$TWITTER_ACCESS_TOKEN
export TWITTER_ACCESS_TOKEN_SECRET=$TWITTER_ACCESS_TOKEN_SECRET
export TWITTER_TEXT=TWITTER_TEXT

# Cosmos DB
export COSMOS_DB_ENDPOINT=$COSMOS_DB_ENDPOINT
export COSMOS_DB_MASTERKEY=$COSMOS_DB_MASTERKEY
export COSMOS_DB_DATABASE=$AZURE_COSMOS_DB
export COSMOS_DB_COLLECTION=$AZURE_COSMOS_DB
EOF