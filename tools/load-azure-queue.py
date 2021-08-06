from azure.storage.queue import QueueClient
import os
from random import randint

# Azure Storage
azure_queue = os.environ['AZURE_QUEUE']
azure_storage_acct_connection_string = os.environ['AZURE_STORAGE_ACCT_CONNECTION_STRING']

# Build Azure queue object
queue_service = QueueClient.from_connection_string(azure_storage_acct_connection_string, azure_queue)

# Add random number of messages to queue
message_number = randint(100,100)
int = 0

while message_number > 0:
    queue_service.send_message("Kubernetes is so much fun...")
    message_number = message_number - 1
print("Done...")
