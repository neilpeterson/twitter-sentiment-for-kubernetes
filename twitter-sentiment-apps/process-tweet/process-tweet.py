from azure.storage.queue import QueueClient
import pydocumentdb.document_client as document_client
import os
import json
import requests

# Azure Analytics
AZURE_ANALYTICS_URI = os.environ['AZURE_ANALYTICS_URI']
AZURE_ANALYTICS_URI = AZURE_ANALYTICS_URI + "/text/analytics/v3.0/sentiment"
AZURE_ANALYTICS_KEY = os.environ['AZURE_ANALYTICS_KEY']

# Azure Storage
AZURE_STORAGE_ACCT_CONNECTION_STRING = os.environ['AZURE_STORAGE_ACCT_CONNECTION_STRING']
AZURE_QUEUE = os.environ['AZURE_QUEUE']

# Cosmos DB
COSMOS_DB_ENDPOINT = os.environ['COSMOS_DB_ENDPOINT']
COSMOS_DB_MASTERKEY = os.environ['COSMOS_DB_MASTERKEY']
COSMOS_DB_DATABASE = os.environ['COSMOS_DB_DATABASE']
COSMOS_DB_COLLECTION = os.environ['COSMOS_DB_COLLECTION']

# Build queue object
QUEUE_SERVICE = QueueClient.from_connection_string(AZURE_STORAGE_ACCT_CONNECTION_STRING, AZURE_QUEUE)

# Build Cosmos DB client
client = document_client.DocumentClient(COSMOS_DB_ENDPOINT, {'masterKey': COSMOS_DB_MASTERKEY})

# Start Functions

# Initialize Cosmos DB
def cosmosdb():

    # Check for database - quick hack /fix up proper
    try:
        db = next((data for data in client.ReadDatabases() if data['id'] == COSMOS_DB_DATABASE))
    # Create if missing
    except:
        db = client.CreateDatabase({'id': COSMOS_DB_DATABASE})

    # Check for collection - quick hack /fix up proper
    try:
        collection = next((coll for coll in client.ReadCollections(db['_self']) if coll['id'] == COSMOS_DB_COLLECTION))
    # Create if missing
    except:
        options = {
            'offerEnableRUPerMinuteThroughput': True,
            'offerVersion': "V2",
            'offerThroughput': 400
        }

        # Create a collection
        collection = client.CreateCollection(db['_self'], {'id': COSMOS_DB_COLLECTION}, options)

    # Return collection
    return collection

# Get Azure Queue count
def queue_count():
    messages = QUEUE_SERVICE.receive_messages(messages_per_page=1)
    return messages

# Get sentiment
def analytics(text):
    headers = {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': AZURE_ANALYTICS_KEY,
    }

    payload = {
    "documents": [
        {
        "language": "en",
        "id": "apex-demo",
        "text": text
        }
    ]
    }

    r = requests.post(AZURE_ANALYTICS_URI, data=json.dumps(payload), headers=headers)

    print(r.text)
   
    try:
        return json.loads(r.text)['documents'][0]['sentiment']
    except:
        print("Analytics error.")

# Add tweet and sentiment score to Cosmos DB
def add_tweet_cosmosdb(messgae, sentiment):
    client.CreateDocument(collection['_self'],
        {
            'message': messgae,
            'sentiment': sentiment
        })

# Delete Azure Queue message
def delete_queue_message(queue, message):
    QUEUE_SERVICE.delete_message(message)

## Start Main

# Initalize Cosmos DB
collection = cosmosdb()

while True:

    # Get tweets from Azure Queue
    returned_messages = queue_count()

    # Loop tweets
    for message in returned_messages:

        # Get sentiment
        returned_sentiment = analytics(message.content)
        print(returned_sentiment)

        # Add tweet and sentiment score to Cosmos DB
        add_tweet_cosmosdb(message.content, returned_sentiment)

        # Delete message from queue
        delete_queue_message(AZURE_QUEUE, message)
