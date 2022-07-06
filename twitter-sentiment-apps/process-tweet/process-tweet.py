import os
import json
from azure.servicebus import ServiceBusClient, ServiceBusMessage
import pydocumentdb.document_client as document_client
import requests

# Azure Analytics
azure_analytics_uri = os.environ['AZURE_ANALYTICS_URI']
# Why duplicated variable
azure_analytics_uri = azure_analytics_uri + "/text/analytics/v3.0/sentiment"
azure_analytics_key = os.environ['AZURE_ANALYTICS_KEY']

# Azure Service Bus connection details
CONNECTION_STR = os.environ['SERVICE_BUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICE_BUS_QUEUE_NAME"]

# Cosmos DB
cosmos_db_endpoint = os.environ['COSMOS_DB_ENDPOINT']
cosmos_db_masterkey = os.environ['COSMOS_DB_MASTERKEY']
cosmos_db_database = os.environ['COSMOS_DB_DATABASE']
cosmos_db_collection = os.environ['COSMOS_DB_COLLECTION']

# Service Bus client and queue sender
servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)
sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)

# Build Cosmos DB client
client = document_client.DocumentClient(cosmos_db_endpoint, {'masterKey': cosmos_db_masterkey})

# Start Functions

# Initialize Cosmos DB
def cosmosdb():

    # Check for database - quick hack /fix up proper
    try:
        db = next((data for data in client.ReadDatabases() if data['id'] == cosmos_db_database))
    # Create if missing
    except:
        db = client.CreateDatabase({'id': cosmos_db_database})

    # Check for collection - quick hack /fix up proper
    try:
        collection = next((coll for coll in client.ReadCollections(db['_self']) if coll['id'] == cosmos_db_collection))
    # Create if missing
    except:
        options = {
            'offerEnableRUPerMinuteThroughput': True,
            'offerVersion': "V2",
            'offerThroughput': 400
        }

        # Create a collection
        collection = client.CreateCollection(db['_self'], {'id': cosmos_db_collection}, options)

    # Return collection
    return collection

# Get Azure Queue count
def queue_count():
    # < TODO - here I am >
    messages = queue_service.receive_messages(messages_per_page=1)
    return messages

# Get sentiment
def analytics(text):
    headers = {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': azure_analytics_key,
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

    r = requests.post(azure_analytics_uri, data=json.dumps(payload), headers=headers)

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
    queue_service.delete_message(message)

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
        delete_queue_message(azure_queue, message)
