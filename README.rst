# Twitter Sentiment to Cosmos DB

## Get Tweets

- Collects tweets based on a key word.
- Stores these in an Azure Queue.

## Process Tweets

- Get Tweets from Azure Queue
- Get sentiment of Tweet from Azure Analytics
- Puts Tweet message and sentiment score into a Cosmos DB
