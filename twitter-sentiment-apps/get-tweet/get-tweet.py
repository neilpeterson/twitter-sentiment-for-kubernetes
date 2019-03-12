from azure.storage.queue import QueueService
import os
import json
import tweepy

# Azure Storage
AZURE_STORAGE_ACCT = os.environ['AZURE_STORAGE_ACCT']
AZURE_QUEUE = os.environ['AZURE_QUEUE']
AZURE_QUEUE_KEY = os.environ['AZURE_QUEUE_KEY']

# Twitter
TWITTER_CONSUMER_KEY = os.environ['TWITTER_CONSUMER_KEY']
TWITTER_CONSUMER_SECRET = os.environ['TWITTER_CONSUMER_SECRET']
TWITTER_ACCESS_TOKEN = os.environ['TWITTER_ACCESS_TOKEN']
TWITTER_ACCESS_TOKEN_SECRET = os.environ['TWITTER_ACCESS_TOKEN_SECRET']
TWITTER_TEXT = os.environ['TWITTER_TEXT']

# # KILL SWITCH
# def kill_switch():

#     # Simple operation for Kubernetes postStop hook
#     if os.path.exists("/kill_switch"):
#         print("Stop processing due to kill switch.")
#         sys.exit(1)

# Authenticate with Twitter
auth = tweepy.OAuthHandler(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
auth.set_access_token(TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)
api = tweepy.API(auth)

# Build Azure queue object
queue_service = QueueService(account_name=AZURE_STORAGE_ACCT, account_key=AZURE_QUEUE_KEY)

# Check for queue / create queue
queue = queue_service.list_queues()

queueName = False

for i in queue:
    if AZURE_QUEUE == i.name:
        queueName = True

if not queueName:
    print("Create Queue")
    queue_service.create_queue(AZURE_QUEUE)
else:
    print("Queue exsists")

# Define Tweepy stream class
class MyStreamListener(tweepy.StreamListener):

    def on_status(self, status):

        # Filter out re-tweet is env variable is set
        if "FILTER_RETWEET" in os.environ:
            if (not status.retweeted) and ('RT @' not in status.text):
                print(status.text)
                queue_service.put_message(AZURE_QUEUE, status.text)
        else:
            print(status.text)
            queue_service.put_message(AZURE_QUEUE, status.text)

    def on_error(self, status):
        print('Error')

# Twitter Stream
listener = MyStreamListener()
stream = tweepy.Stream(auth, listener)
setTerms = [TWITTER_TEXT]
stream.filter(track = setTerms)
