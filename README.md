[![Build Status](https://nepeters-devops.visualstudio.com/twitter-sentiment-for-kubernetes/_apis/build/status/twitter-sentiment-for-kubernetes-CI?branchName=master)](https://nepeters-devops.visualstudio.com/twitter-sentiment-for-kubernetes/_build/latest?definitionId=9?branchName=master)

# Twitter Sentiment to Cosmos DB

Collects tweets, gets sentiments of tweets, stores, and visualizes results.

![application architecture](/images/app.png)

A Helm Chart for deploying this solution with the Kubernetes Service Catalog can be found [here](https://github.com/Azure-Samples/helm-charts/tree/master/chart-source/twitter-sentiment).

### [Get Tweets](../../tree/master/twitter-sentiment-apps/get-tweet)

Collects tweets based on a key word and stores the tweet text in an Azure Queue.

### [Process Tweets](../../tree/master/twitter-sentiment-apps/process-tweet)

Get Tweets from Azure Queue, performs sentiment analysis using Azure Analytics, and stores the results in Cosmos DB.

### [Chart Tweets](../../tree/master/twitter-sentiment-apps/chart-tweet)

Creates a pie chart with tweet sentiment results.
