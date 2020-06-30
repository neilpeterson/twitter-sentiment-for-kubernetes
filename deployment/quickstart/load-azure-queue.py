from azure.storage.queue import QueueService
import os
from random import randint
import time

# Grab environment variables.
AZURE_STORAGE_ACCT = os.environ['AZURE_STORAGE_ACCT']
AZURE_QUEUE = os.environ['AZURE_QUEUE']
AZURE_QUEUE_KEY = os.environ['AZURE_QUEUE_KEY']

# Build queue object
queue_service = QueueService(account_name=AZURE_STORAGE_ACCT, account_key=AZURE_QUEUE_KEY) 

int = 0

# Add random number of messages to queue
message_number = randint(100,100)

while message_number > 0:    
    
    queue_service.put_message(AZURE_QUEUE, "Kubernetes is so much fun...")
    message_number = message_number - 1

print("Done...")
        
