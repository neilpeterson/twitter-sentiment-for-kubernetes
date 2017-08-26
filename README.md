# Twitter Sentiment to Cosmos DB

### [Get Tweets](../../twitter-sentiment-apps/get-tweet)

- Collects tweets based on a key word.
- Stores these in an Azure Queue.

### [Process Tweets](../../twitter-sentiment-apps/process-tweet)

- Get Tweets from Azure Queue.
- Get sentiment of Tweet from Azure Analytics.
- Puts Tweet message and sentiment score into a Cosmos DB.

### [Chart Tweets](../../twitter-sentiment-apps/chart-tweet)

- Creates a pie chart with tweet sentiment results.

# Quick Start:

## Prerequisites

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

## Create Azure Queue, Cognitive Services Text Sentiment API, and Cosmos DB. 

Copy the `build-twitter-sentiment.sh` script to your development machine. The script can be founder [here](./demo-creation-script/build-twitter-sentiment.sh).

Update the script with your Twitter application information and the text that you want use to filter returned tweets. 

```
# Twitter API Endpoint and Credentials - this is not automated so must be specified.
TWITTER_CONSUMER_KEY=replace
TWITTER_CONSUMER_SECRET=replace
TWITTER_ACCESS_TOKEN=replace
TWITTER_ACCESS_TOKEN_SECRET=replace

# Twitter search term - used to filter returned tweets.
TWITTER_TEXT=Seattle
```

Once complete, run the script.

```
sh twitter-sentiment.sh
```

## Start the Application

The included script not only creates the required Azure resource, it also creates pre-populated Kubernetes manifest files that can be used to start the application. The manifest file is located in the directory from which the script was run.

Note – the Azure secrets are not secured in a Kubernetes secret.

The manifest creates the following Kubernetes objects:

- Get Tweet Deployment – gets tweets from Twitter streaming API, places the text on an Azure Queue.
- Process Tweet Deployment – gets tweets from Azure Queue, returns text sentiment score, puts this into a Cosmos DB.
- Chart Tweets Deployment – Retrieves and charts the tweet sentiment.
- Cart Tweets Service – exposes the chart to the internet.

```
kubectl create -f twitter-sentiment.yml
```

Output:

```
deployment "process-tweet" created
deployment "get-tweet" created
deployment "chart-tweet" created
service "chart-tweet" created
```

The Chart Tweet service can take some time to complete. To want progress, start a watch on the ‘kubectl get service’ command.

```
kubectl get service -w
```

Once a public IP address has been return browse to this IP address to see the retuned sentiment results.

![Image of tweet sentiment chart](media/chart.png)

## Caution

Once the application starts, tweets are immediately captured, stored in the Azure Queue, and processed. While the application is running, it will incur an Azure cost. As the number of returned tweets increases, so does the Azure spend.

