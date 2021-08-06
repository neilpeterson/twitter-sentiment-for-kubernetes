#!/bin/bash

RANDOMVALUE=$RANDOM

# Twitter API Endpoint and Credentials - this is not automated so must be specified.
TWITTER_CONSUMER_KEY=$TWITTER_CONSUMER_KEY
TWITTER_CONSUMER_SECRET=$TWITTER_CONSUMER_SECRET
TWITTER_ACCESS_TOKEN=$TWITTER_ACCESS_TOKEN
TWITTER_ACCESS_TOKEN_SECRET=$TWITTER_ACCESS_TOKEN_SECRET

# Twitter search term - used to filter returned tweets.
TWITTER_TEXT=$TWITTER_TEXT

# Names for the Azure Resource Group, Storage Account, and Cosmos DB name.
AZURE_RESOURCE_GROUP=tweet-factory-$RANDOMVALUE
AZURE_STORAGE_ACCT=tweetfactory$RANDOMVALUE
AZURE_COSMOS_DB=tweetfactory$RANDOMVALUE
AZURE_ANALYTICS=tweetfactory$RANDOMVALUE

# Create resource group
az group create --name $AZURE_RESOURCE_GROUP --location eastus

# Create storage account
az storage account create --name $AZURE_STORAGE_ACCT --resource-group $AZURE_RESOURCE_GROUP --sku Standard_LRS

# Create storage queue
az storage queue create --name $AZURE_STORAGE_ACCT --account-name $AZURE_STORAGE_ACCT

# Create Comsmos DB
az cosmosdb create --name $AZURE_COSMOS_DB --resource-group $AZURE_RESOURCE_GROUP

# Create Congnitive Services API
az cognitiveservices account create --name $AZURE_ANALYTICS --resource-group $AZURE_RESOURCE_GROUP --kind TextAnalytics --sku F0 --location eastus

# Get endpoints and keys
AZURE_STORAGE_ACCT_CONNECTION_STRING=$(az storage account show-connection-string --name $AZURE_STORAGE_ACCT --resource-group $AZURE_RESOURCE_GROUP -o tsv)
COSMOS_DB_ENDPOINT=$(az cosmosdb show --name $AZURE_COSMOS_DB --resource-group $AZURE_RESOURCE_GROUP --query documentEndpoint -o tsv)
COSMOS_DB_MASTERKEY=$(az cosmosdb list-keys --name $AZURE_COSMOS_DB --resource-group $AZURE_RESOURCE_GROUP --query primaryMasterKey -o tsv)
AZURE_ANALYTICS_ENDPOINT=$(az cognitiveservices account show --resource-group $AZURE_RESOURCE_GROUP --name $AZURE_ANALYTICS --query properties.endpoint -o tsv)
AZURE_ANALYTICS_KEY=$(az cognitiveservices account keys list --resource-group $AZURE_RESOURCE_GROUP --name $AZURE_ANALYTICS --query key1 -o tsv)

# Create Twitter Sentiment Manifest
cat <<EOF > twitter-sentiment-kubernetes-manifest.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: get-tweet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: get-tweet
  template:
    metadata:
      labels:
        app: get-tweet
    spec:
      containers:
      - name: get-tweet
        image: neilpeterson/get-tweet:v4
        env:
        - name: AZURE_QUEUE
          value: $AZURE_STORAGE_ACCT
        - name: AZURE_STORAGE_ACCT_CONNECTION_STRING
          value: $AZURE_STORAGE_ACCT_CONNECTION_STRING
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
apiVersion: apps/v1
kind: Deployment
metadata:
  name: process-tweet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: process-tweet
  template:
    metadata:
      labels:
        app: process-tweet
    spec:
      containers:
      - name: process-tweet
        image: neilpeterson/process-tweet:v4
        env:
        - name: AZURE_ANALYTICS_URI
          value: $AZURE_ANALYTICS_ENDPOINT
        - name: AZURE_ANALYTICS_KEY
          value: $AZURE_ANALYTICS_KEY
        - name: AZURE_STORAGE_ACCT_CONNECTION_STRING
          value: $AZURE_STORAGE_ACCT_CONNECTION_STRING
        - name: AZURE_QUEUE
          value: $AZURE_STORAGE_ACCT
        - name: COSMOS_DB_ENDPOINT
          value: $COSMOS_DB_ENDPOINT
        - name: COSMOS_DB_MASTERKEY
          value: $COSMOS_DB_MASTERKEY
        - name:  COSMOS_DB_DATABASE
          value: $AZURE_COSMOS_DB
        - name:  COSMOS_DB_COLLECTION
          value: $AZURE_COSMOS_DB
        lifecycle:
          preStop:
              exec:
                command: ["bin/sh","-c","touch /kill_switch"]
      terminationGracePeriodSeconds: 2
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chart-tweet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chart-tweet
  template:
    metadata:
      labels:
        app: chart-tweet
    spec:
      containers:
      - name: chart-tweet
        image: neilpeterson/chart-tweet:v4
        env:
        - name: COSMOS_DB_ENDPOINT
          value: $COSMOS_DB_ENDPOINT
        - name: COSMOS_DB_MASTERKEY
          value: $COSMOS_DB_MASTERKEY
        - name:  COSMOS_DB_DATABASE
          value: $AZURE_COSMOS_DB
        - name:  COSMOS_DB_COLLECTION
          value: $AZURE_COSMOS_DB
        - name:  CHART_LABEL
          value: $TWITTER_TEXT
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

# Create Compose File
cat <<EOF > docker-compose.yml
version: '3'
services:
  get-tweet:
    image: neilpeterson/get-tweet:v4
    container_name: get-tweet
    environment:
      AZURE_QUEUE: $AZURE_STORAGE_ACCT
      AZURE_STORAGE_ACCT_CONNECTION_STRING: $AZURE_STORAGE_ACCT_CONNECTION_STRING
      TWITTER_CONSUMER_KEY: $TWITTER_CONSUMER_KEY
      TWITTER_CONSUMER_SECRET: $TWITTER_CONSUMER_SECRET
      TWITTER_ACCESS_TOKEN: $TWITTER_ACCESS_TOKEN
      TWITTER_ACCESS_TOKEN_SECRET: $TWITTER_ACCESS_TOKEN_SECRET
      TWITTER_TEXT: $TWITTER_TEXT
  process-tweet:
    image: neilpeterson/process-tweet:v4
    container_name: process-tweet
    environment:
      AZURE_ANALYTICS_URI: $AZURE_ANALYTICS_ENDPOINT
      AZURE_ANALYTICS_KEY: $AZURE_ANALYTICS_KEY
      AZURE_QUEUE: $AZURE_STORAGE_ACCT
      AZURE_STORAGE_ACCT_CONNECTION_STRING: $AZURE_STORAGE_ACCT_CONNECTION_STRING
      COSMOS_DB_ENDPOINT: $COSMOS_DB_ENDPOINT
      COSMOS_DB_MASTERKEY: $COSMOS_DB_MASTERKEY
      COSMOS_DB_DATABASE: $AZURE_COSMOS_DB
      COSMOS_DB_COLLECTION: $AZURE_COSMOS_DB
  chart-tweet:
    image: neilpeterson/chart-tweet:v4
    container_name: chart-tweet
    environment:
      COSMOS_DB_ENDPOINT: $COSMOS_DB_ENDPOINT
      COSMOS_DB_MASTERKEY: $COSMOS_DB_MASTERKEY
      COSMOS_DB_DATABASE: $AZURE_COSMOS_DB
      COSMOS_DB_COLLECTION: $AZURE_COSMOS_DB
      CHART_LABEL: $TWITTER_TEXT
    ports:
      - "8080:80"
EOF

# Create environment variables, these can be used to run the python files.
cat <<EOF > twitter-sentiment-environment-variables.sh
# Azure Analytics
export AZURE_ANALYTICS_URI=$AZURE_ANALYTICS_ENDPOINT
export AZURE_ANALYTICS_KEY=$AZURE_ANALYTICS_KEY

# Azure Storage
export AZURE_QUEUE=$AZURE_STORAGE_ACCT
export AZURE_STORAGE_ACCT_CONNECTION_STRING='$AZURE_STORAGE_ACCT_CONNECTION_STRING'

# Twitter
export TWITTER_CONSUMER_KEY=$TWITTER_CONSUMER_KEY
export TWITTER_CONSUMER_SECRET=$TWITTER_CONSUMER_SECRET
export TWITTER_ACCESS_TOKEN=$TWITTER_ACCESS_TOKEN
export TWITTER_ACCESS_TOKEN_SECRET=$TWITTER_ACCESS_TOKEN_SECRET
export TWITTER_TEXT=$TWITTER_TEXT

# Cosmos DB
export COSMOS_DB_ENDPOINT=$COSMOS_DB_ENDPOINT
export COSMOS_DB_MASTERKEY=$COSMOS_DB_MASTERKEY
export COSMOS_DB_DATABASE=$AZURE_COSMOS_DB
export COSMOS_DB_COLLECTION=$AZURE_COSMOS_DB

# Create HELM Values
cat <<EOF > values.yaml
# Twitter
TWITTER_CONSUMER_KEY: $TWITTER_CONSUMER_KEY
TWITTER_CONSUMER_SECRET: $TWITTER_CONSUMER_SECRET
TWITTER_ACCESS_TOKEN: $TWITTER_ACCESS_TOKEN
TWITTER_ACCESS_TOKEN_SECRET: $TWITTER_ACCESS_TOKEN_SECRET
TWITTER_TEXT: $TWITTER_TEXT

# Azure
AZURE_QUEUE: $AZURE_STORAGE_ACCT
AZURE_STORAGE_ACCT_CONNECTION_STRING: $AZURE_STORAGE_ACCT_CONNECTION_STRING
AZURE_ANALYTICS_URI: $AZURE_ANALYTICS_ENDPOINT
AZURE_ANALYTICS_KEY: $AZURE_ANALYTICS_KEY
COSMOS_DB_ENDPOINT: $COSMOS_DB_ENDPOINT
COSMOS_DB_MASTERKEY: $COSMOS_DB_MASTERKEY
COSMOS_DB_DATABASE: $AZURE_COSMOS_DB
COSMOS_DB_COLLECTION: $AZURE_COSMOS_DB

# Images
imageRegistry: neilpeterson
imageVersion: v4
EOF

# # Create TMUX script
# # Come back to this someday (maybe)
# cat <<EOF > tmux.sh
# #!/bin/bash

# tmux new -s work -d
# tmux send-keys -t work 'export AZURE_STORAGE_ACCT=$AZURE_STORAGE_ACCT' C-m
# tmux send-keys -t work 'export AZURE_QUEUE=$AZURE_STORAGE_ACCT' C-m
# tmux send-keys -t work 'export AZURE_QUEUE_KEY=$AZURE_QUEUE_KEY' C-m
# tmux send-keys -t work 'virtualenv -p python3 venv;source venv/bin/activate' C-m
# tmux send-keys -t work 'pip install azure-storage; tmux wait-for -S pip-install' C-m\; wait-for pip-install
# tmux send-keys -t work 'clear' C-m
# tmux split-window -v -t work
# tmux send-keys -t work 'export AZURE_STORAGE_ACCT=$AZURE_STORAGE_ACCT' C-m
# tmux send-keys -t work 'export AZURE_QUEUE=$AZURE_STORAGE_ACCT' C-m
# tmux send-keys -t work 'export AZURE_QUEUE_KEY=$AZURE_QUEUE_KEY' C-m
# tmux send-keys -t work 'source venv/bin/activate' C-m
# tmux send-keys -t work 'clear' C-m
# tmux send-keys -t work 'python azure-queue-count.py' C-m
# tmux split-window -h -t work
# tmux send-keys -t work 'while \$true; do kubectl get pods -l app=process-tweet; sleep .5; done' C-m
# tmux attach -t work

# # Come back to this someday (maybe)
# # Create Kubernetes CRD Manifest for auto scaling Twitter Sentiment
# cat <<EOF > twitter-sentiment-kubernetes-crd.yml
# apiVersion: apiextensions.k8s.io/v1beta1
# kind: CustomResourceDefinition
# metadata:
#   name: azurequeues.apex-sample.com
# spec:
#   group: apex-sample.com
#   version: v1
#   scope: Namespaced
#   names:
#     plural: azurequeues
#     singular: azurequeue
#     kind: AzureQueue
#     shortNames:
#     - aq
# ---
# apiVersion: "apex-sample.com/v1"
# kind: AzureQueue
# metadata:
#   name: process-tweet
# spec:
#   AZURESTORAGEACCT: $AZURE_STORAGE_ACCT
#   AZUREQUEUE: $AZURE_STORAGE_ACCT
#   AZUREQUEUEKEY: $AZURE_QUEUE_KEY
#   QUEUELENGTH: 10
#   MIN_REPLICA: 1
#   MAX_REPLICA: 3
#   DEPLOYMENTNAME: process-tweet
# ---
# apiVersion: apps/v1beta1
# kind: Deployment
# metadata:
#   name: kube-azure-queue-controller
# spec:
#   replicas: 1
#   template:
#     metadata:
#       labels:
#         app: kube-azure-queue-controller
#     spec:
#       containers:
#       - name: kubectl-sidecar
#         image: neilpeterson/kubectl-proxy-sidecar
#       - name: kube-azure-queue-controller
#         image: neilpeterson/azure-queue-controller
# EOF