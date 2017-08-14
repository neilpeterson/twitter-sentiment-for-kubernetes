# Twitter Sentiment to Cosmos DB

### Get Tweets

- Collects tweets based on a key word
- Stores these in an Azure Queue

### Process Tweets

- Get Tweets from Azure Queue
- Get sentiment of Tweet from Azure Analytics
- Puts Tweet message and sentiment score into a Cosmos DB

## Get Tweets

### Prerequisites

The get tweets application has been written in Python 3.

The get tweets application requires an Azure Storage Queue and a Twitter application. The Azure Storage Queue can be configured using the instruction  found on [docs.microsoft.com](https://docs.microsoft.com/en-us/azure/storage/storage-python-how-to-use-queue-storage).

This Twitter application can be configured on the [Twitter development center](https://dev.twitter.com/#).

### Environment variables

```
# Azure Storage
export AZURE_STORAGE_ACCT=kubeazurequeue
export AZURE_QUEUE=kubeazurequeue 
export AZURE_QUEUE_KEY=0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

# Twitter
export TWITTER_CONSUMER_KEY=000000000000000000000000
export TWITTER_CONSUMER_SECRET=000000000000000000000000000000000000000000000000
export TWITTER_ACCESS_TOKEN=000000000-000000000000000000000000000000000000000000000000
export TWITTER_ACCESS_TOKEN_SECRET=000000000000000000000000000000000000000000000000
export TWITTER_TEXT=seattle
```

### Execution

The `get-tweet.py` files is found at `.twitter-sentiment-cosmosdb/get-tweet/get-tweet.py`.

Run the following to begin catching tweets and storing them in an Azure Queue.

```
python get-tweet.py
```

## Process Tweets

### Prerequisites

The process tweets application has been written in Python 3.

The process tweets application requires an Azure Storage Queue and a Twitter application. The Azure Storage Queue can be configured using the instruction  found on [docs.microsoft.com](https://docs.microsoft.com/en-us/azure/storage/storage-python-how-to-use-queue-storage).

You will also need access to an Azure Analytics Text Sentiment API. For information on creating one, see [Text Analytics API on docs.microsoft.com](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/quick-start).

Finally, you will need a Cosmos DB. For information see, [Cosmos DB on docs.microsoft.com](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction).

### Environment variables

```
# Azure Storage
export AZURE_STORAGE_ACCT=kubeazurequeue
export AZURE_QUEUE=kubeazurequeue
export AZURE_QUEUE_KEY=0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

# Azure Analytics
export AZURE_ANALYTICS_URI=https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment
export AZURE_ANALYTICS_KEY=00000000000000000000000000000000

# Cosmos DB
export COSMOS_DB_ENDPOINT=https://twitter-sentiment.documents.azure.com
export COSMOS_DB_MASTERKEY=0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
export COSMOS_DB_DATABASE=tweet-sentiment
export COSMOS_DB_COLLECTION=tweet-sentiment
```

### Execution

The `process-tweet.py` files is found at `.twitter-sentiment-cosmosdb/process-tweet/process-tweet.py`.

Run the following to begin processing tweets from the Azure Queue. 

```
python process-tweet.py
```

Each one will be evaluated against the Azure Analytics Text Sentiment API. The tweet and Sentiment score will then be stored in an Azure Cosmos DB.
