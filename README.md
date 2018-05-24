# Twitter Sentiment to Cosmos DB

### [Get Tweets](../../tree/master/twitter-sentiment-apps/get-tweet)

Collects tweets based on a key word and stores these in an Azure Queue.

### [Process Tweets](../../tree/master/twitter-sentiment-apps/process-tweet)

Get Tweets from Azure Queue, performs sentiment analysis using Azure Analytics, and stores the results in Cosmos DB.

### [Chart Tweets](../../tree/master/twitter-sentiment-apps/chart-tweet)

Creates a pie chart with tweet sentiment results.

### Custom Kubernetes Auto Scaler

This application was written to demo a custom Kubernetes auto scaler. The auto scaler Custom Resource Definition (CRD) and controller can be found [here](https://github.com/neilpeterson/kubernetes-auto-scale-azure-crd). 

# Videos

[Application Demo](https://youtu.be/qJpv-TwW3w0)

[Application Quickstart](https://youtu.be/v-RobmRUdFg)

[Manual and Auto Scale](http://www.youtube.com/watch?v=J1a4fTb2grg)

# Prerequisites

### Kubernetes Cluster 

You will need a Kubernetes cluster before running the Twitter Sentiment to Cosmos DB application. 

To create a Kubernetes cluster in Azure Container Service, see [ACS Kubernetes Quick Start](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-walkthrough).

### Twitter Application

You also need a registered Twittered application, which can be created at [https://apps.twitter.com]( https://apps.twitter.com).

From this application, you need the following items:

- TWITTER_CONSUMER_KEY
- TWITTER_CONSUMER_SECRET
- TWITTER_ACCESS_TOKEN
- TWITTER_ACCESS_TOKEN_SECRET

### Azure Subscription and CLI

You will need an Azure Subscription and the Azure CLI. 

[Free Azure Trial](https://azure.microsoft.com/en-us/free/?v=17.16&WT.srch=1&WT.mc_id=AID559320_SEM_BXZWtUPg&gclid=CjwKCAjwuITNBRBFEiwA9N9YEEvI-py5W2k4RXJcjHj_GCshHPGDY5DhdrHn3gyd6uXbtJ-7iHsjphoCJr0QAvD_BwE)
[Azure CLI Installation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

# Quick Start

https://github.com/neilpeterson/twitter-sentiment-quick-start
