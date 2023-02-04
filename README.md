# Twitter Sentiment engine

Collects tweets, gets sentiments of tweets, stores, and visualizes results.

#### Get Tweets

The get tweets application uses the Twitter API + Tweepy client to pull tweets based on a key word and places the tweet text on an Azure Service Bus queue for processing.

![application architecture](./docs/images/get-tweet.png)

#### Process Tweets

As tweets arrive in the queue, a second application grabs the tweet text, sends this to an Azure Cognitive Services API to determine a sentiment value (positive, negative, neutral). The results are stored in an Azure Cosmos database.

![application architecture](./docs/images/process-tweet.png)

#### Chart Tweets

Flask app displays the result in a web browser.

![application architecture](./docs/images/chart-tweets.png)

## Prerequisites

You will need a Twitter account and credentials for authentication with Twitter APIs. You can sign up for a Twitter developer account at https://developer.twitter.com/ .

- TWITTER_CONSUMER_KEY
- TWITTER_CONSUMER_SECRET
- TWITTER_ACCESS_TOKEN
- TWITTER_ACCESS_TOKEN_SECRET

You also need an Azure account, the Azure CLI installed and authenticated, and a pre-created Kubernetes cluster.

## Quickstarts

This solution works locally (with Azure backend), in Azure Container Apps, and Kubernetes. Steps for eaach deployment option can be found in the following documents.

- [Quickstart Local Execution](./docs/quickstart-local.md)
- [Quickstart Local Execution with Dapr](./docs/quickstart-local-dapr.md)
- [Quickstart Azure Container Apps](./docs/quickstart-azure-container-apps.md)
- [Quickstart Kubernetes](./docs/quickstart-kubernetes.md)