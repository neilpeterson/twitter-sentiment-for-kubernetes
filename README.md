# Twitter Sentiment to Cosmos DB

Collects tweets, gets sentiments of tweets, stores, and visualizes results.

![application architecture](/images/app.png)

### [Get Tweets](../../tree/master/twitter-sentiment-apps/get-tweet)

Collects tweets based on a key word and stores the tweet text in an Azure Queue.

### [Process Tweets](../../tree/master/twitter-sentiment-apps/process-tweet)

Get Tweets from Azure Queue, performs sentiment analysis using Azure Analytics, and stores the results in Cosmos DB.

### [Chart Tweets](../../tree/master/twitter-sentiment-apps/chart-tweet)

Creates a pie chart with tweet sentiment results.

# Videos

[Application Demo](https://youtu.be/qJpv-TwW3w0)

[Application Quickstart](https://youtu.be/v-RobmRUdFg)

[Manual and Auto Scale](http://www.youtube.com/watch?v=J1a4fTb2grg)

# Quickstart

The [quickstart](./quickstart) includes scripts for creating the necessary Azure infrastructure and Kubernetes manifests.
