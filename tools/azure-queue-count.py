import os
from azure.storage.queue import QueueClient
import time

# Azure Storage
azure_queue = os.environ['AZURE_QUEUE']
azure_storage_acct_connection_string = os.environ['AZURE_STORAGE_ACCT_CONNECTION_STRING']

# Build Azure queue object
queue_service = QueueClient.from_connection_string(azure_storage_acct_connection_string, azure_queue)

while True: 
    properties = queue_service.get_queue_properties()
    queue_length = properties.approximate_message_count
    print(queue_length)