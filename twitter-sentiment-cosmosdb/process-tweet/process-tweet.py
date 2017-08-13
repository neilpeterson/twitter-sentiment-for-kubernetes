from azure.storage.queue import QueueService
import pydocumentdb
import pydocumentdb.document_client as document_client
import os
import json
import requests

# Azure Analytics
AZURE_ANALYTICS_URI = os.environ['AZURE_ANALYTICS_URI']
AZURE_ANALYTICS_KEY = os.environ['AZURE_ANALYTICS_KEY']

# Azure Storage
AZURE_STORAGE_ACCT = os.environ['AZURE_STORAGE_ACCT']
AZURE_QUEUE = os.environ['AZURE_QUEUE']
AZURE_QUEUE_KEY = os.environ['AZURE_QUEUE_KEY']

# Cosmos DB
COSMOS_DB_ENDPOINT = os.environ['COSMOS_DB_ENDPOINT']
COSMOS_DB_MASTERKEY = os.environ['COSMOS_DB_MASTERKEY']
COSMOS_DB_DATABASE = os.environ['COSMOS_DB_DATABASE']
COSMOS_DB_COLLECTION = os.environ['COSMOS_DB_COLLECTION']

# Build queue object
QUEUE_SERVICE = QueueService(account_name=AZURE_STORAGE_ACCT, account_key=AZURE_QUEUE_KEY)

# Build Cosmos DB client
client = document_client.DocumentClient(COSMOS_DB_ENDPOINT, {'masterKey': COSMOS_DB_MASTERKEY})

############# Start Functions

# Get text sentiment from Azure Analytics
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
    return json.loads(r.text)['documents'][0]['score']

# Get Azure Queue count
def queue_count():
    metadata = QUEUE_SERVICE.get_queue_metadata(AZURE_QUEUE)
    queue_length = metadata.approximate_message_count
    messages = QUEUE_SERVICE.get_messages(AZURE_QUEUE, num_messages=1)
    return messages

# Delete Azure Queue message
def delete_queue_message(queue, id, pop_receipt):
    QUEUE_SERVICE.delete_message(queue,id,pop_receipt)

# Initialize Cosmos DB
def cosmosdb():

    # Quick hack - fix up proper
    # Check for database
    try:
        db = next((data for data in client.ReadDatabases() if data['id'] == COSMOS_DB_DATABASE))
    except:
        db = client.CreateDatabase({'id': COSMOS_DB_DATABASE})

    # Quick hack - fix up proper
    # Check for collection
    try:
        collection = next((coll for coll in client.ReadCollections(db['_self']) if coll['id'] == COSMOS_DB_COLLECTION))
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

# Add tweet and sentiment score to Cosmos DB
def add_tweet_cosmosdb(messgae,sentiment):
    client.CreateDocument(collection['_self'],
        {
            'message': messgae,
            'sentiment': sentiment
        })

# KILL SWITCH
def kill_switch():
    if "KILL_SWITCH" in os.environ:
        print("Stop processing due to kill switch.")
        sys.exit(1)

############# End Functions

# Initalize Cosmos DB
collection = cosmosdb()

while True:

    # Kill switch can be set to stop queue message processing.
    # This can be used with Kubernetes preStop hook for graceful scale down.
    kill_switch()

    # Get tweets from Azure Queue
    returned_messages = queue_count()

    # Loop tweets
    for message in returned_messages:

        # Get sentiment
        returned_sentiment = analytics(message.content)
        print(returned_sentiment)

        # Add tweet and sentiment score to Cosmos DB
        add_tweet_cosmosdb(message.content,returned_sentiment)

        # Delete message from queue
        delete_queue_message(AZURE_QUEUE,message.id, message.pop_receipt)