import os
from azure.storage.queue import QueueClient
import time

# Azure Storage
AZURE_QUEUE = os.environ['AZURE_QUEUE']
AZURE_STORAGE_ACCT_CONNECTION_STRING = os.environ['AZURE_STORAGE_ACCT_CONNECTION_STRING']

# Build Azure queue object
QUEUE_SERVICE = QueueClient.from_connection_string(AZURE_STORAGE_ACCT_CONNECTION_STRING, AZURE_QUEUE)

while True: 
    properties = QUEUE_SERVICE.get_queue_properties()
    queue_length = properties.approximate_message_count
    print(queue_length)