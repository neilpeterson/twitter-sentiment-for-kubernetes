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

# Authenticate with Twitter
auth = tweepy.OAuthHandler(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
auth.set_access_token(TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)
api = tweepy.API(auth)

# Build Azure queue object
queue_service = QueueService(account_name=AZURE_STORAGE_ACCT, account_key=AZURE_QUEUE_KEY)

# Define Tweepy stream class
class MyStreamListener(tweepy.StreamListener):

    def on_status(self, status):
        
        # Filter out re-tweet
        if (not status.retweeted) and ('RT @' not in status.text):
            print(status.text)
            queue_service.put_message(AZURE_QUEUE, status.text)

    def on_error(self, status):
        print('Error')

# Twitter Stream
listener = MyStreamListener()
stream = tweepy.Stream(auth, listener)
setTerms = [TWITTER_TEXT]
stream.filter(track = setTerms)