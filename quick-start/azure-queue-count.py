import os
from azure.storage.queue import QueueService
import time

# Grab environment variables.
AZURE_STORAGE_ACCT = os.environ['AZURE_STORAGE_ACCT']
AZURE_QUEUE = os.environ['AZURE_QUEUE']
AZURE_QUEUE_KEY = os.environ['AZURE_QUEUE_KEY']

# Build queue object
queue_service = QueueService(account_name=AZURE_STORAGE_ACCT, account_key=AZURE_QUEUE_KEY)

while True: 

    # Get queue count
    metadata = queue_service.get_queue_metadata(AZURE_QUEUE)
    queue_length = metadata.approximate_message_count
    print(queue_length)