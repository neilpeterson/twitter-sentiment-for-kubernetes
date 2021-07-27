from azure.storage.queue import QueueClient
import os
from random import randint

# Azure Storage
AZURE_QUEUE = os.environ['AZURE_QUEUE']
AZURE_STORAGE_ACCT_CONNECTION_STRING = os.environ['AZURE_STORAGE_ACCT_CONNECTION_STRING']

# Build Azure queue object
QUEUE_SERVICE = QueueClient.from_connection_string(AZURE_STORAGE_ACCT_CONNECTION_STRING, AZURE_QUEUE)

# Add random number of messages to queue
message_number = randint(100,100)
int = 0

while message_number > 0:
    QUEUE_SERVICE.send_message("Kubernetes is so much fun...")
    message_number = message_number - 1
print("Done...")
