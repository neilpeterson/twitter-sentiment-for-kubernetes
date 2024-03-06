import os
import json
from tweepy import Stream
from dapr.clients import DaprClient
import logging

# Twitter API connection details
twitter_consumer_key = os.environ['TWITTER_CONSUMER_KEY']
twitter_consumer_secret = os.environ['TWITTER_CONSUMER_SECRET']
twitter_accesss_token = os.environ['TWITTER_ACCESS_TOKEN']
twitter_access_token_secret = os.environ['TWITTER_ACCESS_TOKEN_SECRET']
twitter_serarch_string = os.environ['TWITTER_TEXT']

logging.basicConfig(level = logging.INFO)

# Twitter stream class
class MyStreamListener(Stream):
    def on_status(self, status):

        if (not status.retweeted) and ('RT @' not in status.text):            
            print(status.text, flush=True)

            post = {'tweet': status.text}

            with DaprClient() as client:
                result = client.invoke_binding('twitter-servicebus', 'create', json.dumps(post))
                # logging.basicConfig(level = logging.INFO)
                # logging.info('Sending message: ' + '123')

                print(result)   

    # def on_error(self, status_code):
    #     if status_code == 420:
    #         return False

stream = MyStreamListener(twitter_consumer_key,
                          twitter_consumer_secret,
                          twitter_accesss_token,
                          twitter_access_token_secret)

stream.filter(track=[twitter_serarch_string], languages=["en"])
