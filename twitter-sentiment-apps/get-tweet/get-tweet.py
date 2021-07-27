from azure.storage.queue import QueueClient
import os
import json
import tweepy

# Azure Storage
AZURE_QUEUE = os.environ['AZURE_QUEUE']
AZURE_STORAGE_ACCT_CONNECTION_STRING = os.environ['AZURE_STORAGE_ACCT_CONNECTION_STRING']

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
QUEUE_SERVICE = QueueClient.from_connection_string(AZURE_STORAGE_ACCT_CONNECTION_STRING, AZURE_QUEUE)

# Define Tweepy stream class
class MyStreamListener(tweepy.StreamListener):

    def on_status(self, status):

        # Filter out re-tweet is env variable is set
        if "FILTER_RETWEET" in os.environ:
            if (not status.retweeted) and ('RT @' not in status.text):
                print(status.text)
                QUEUE_SERVICE.send_message(status.text)
        else:
            print(status.text)
            QUEUE_SERVICE.send_message(status.text)

    def on_error(self, status):
        print('Error')

# Twitter Stream
listener = MyStreamListener()
stream = tweepy.Stream(auth, listener)
setTerms = [TWITTER_TEXT]
stream.filter(track = setTerms)
