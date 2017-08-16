# Twitter Sentiment to Cosmos DB

### Get Tweets

- Collects tweets based on a key word
- Stores these in an Azure Queue

### Process Tweets

- Get Tweets from Azure Queue
- Get sentiment of Tweet from Azure Analytics
- Puts Tweet message and sentiment score into a Cosmos DB

### Chart Tweets

- Creates a pie chart with tweet sentiment results.

## Get Tweets

### Prerequisites

- Python 3
- [Azure Storage Queue](https://docs.microsoft.com/en-us/azure/storage/storage-python-how-to-use-queue-storage)
- [Twitter application](https://dev.twitter.com/#)

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

```
python get-tweet.py
```

## Process Tweets

### Prerequisites

- Python 3
- [Azure Storage Queue](https://docs.microsoft.com/en-us/azure/storage/storage-python-how-to-use-queue-storage)
- [Azure Analytics text sentiment API](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/quick-start)
- [Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction)

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

```
python process-tweet.py
```

## Chart Tweets

Python Flask app that reads tweet sentiment from Cosmos DB and creates results pie chart.

### Prerequisites

- Python 3
- [Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction)

### Environment variables

```
# Cosmos DB
export COSMOS_DB_ENDPOINT=https://twitter-sentiment.documents.azure.com
export COSMOS_DB_MASTERKEY=0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
export COSMOS_DB_DATABASE=tweet-sentiment
export COSMOS_DB_COLLECTION=tweet-sentiment
```

### Execution

The `main.py` files is found at `.twitter-sentiment-cosmosdb/chart-tweet/main.py`.

```
python main.py
```
