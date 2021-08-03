from azure.storage.queue import QueueClient
import os
import json
import tweepy

# Azure Storage
azure_queue = os.environ['AZURE_QUEUE']
azure_storage_acct_connection_string = os.environ['AZURE_STORAGE_ACCT_CONNECTION_STRING']

# Twitter
twitter_consumer_key = os.environ['TWITTER_CONSUMER_KEY']
twitter_consumer_secret = os.environ['TWITTER_CONSUMER_SECRET']
twitter_accesss_token = os.environ['TWITTER_ACCESS_TOKEN']
twitter_access_token_secret = os.environ['TWITTER_ACCESS_TOKEN_SECRET']
twitter_serarch_string = os.environ['TWITTER_TEXT']

# Authenticate with Twitter
auth = tweepy.OAuthHandler(twitter_consumer_key, twitter_consumer_secret)
auth.set_access_token(twitter_accesss_token, twitter_access_token_secret)
api = tweepy.API(auth)

# Build Azure queue object
queue_service = QueueClient.from_connection_string(azure_storage_acct_connection_string, azure_queue)

# Define Tweepy stream class
class MyStreamListener(tweepy.StreamListener):

    def on_status(self, status):

        # Filter out re-tweet is env variable is set
        if "FILTER_RETWEET" in os.environ:
            if (not status.retweeted) and ('RT @' not in status.text):
                print(status.text)
                queue_service.send_message(status.text)
        else:
            print(status.text)
            queue_service.send_message(status.text)

    def on_error(self, status):
        print('Error')

# Twitter Stream
listener = MyStreamListener()
stream = tweepy.Stream(auth, listener)
setTerms = [twitter_serarch_string]
stream.filter(track = setTerms)
