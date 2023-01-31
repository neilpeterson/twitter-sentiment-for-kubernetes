import os
import json
from tweepy import Stream
from azure.servicebus import ServiceBusClient, ServiceBusMessage

# Azure Service Bus connection details
CONNECTION_STR = os.environ['SERVICE_BUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICE_BUS_QUEUE_NAME"]

# Twitter API connection details
twitter_consumer_key = os.environ['TWITTER_CONSUMER_KEY']
twitter_consumer_secret = os.environ['TWITTER_CONSUMER_SECRET']
twitter_accesss_token = os.environ['TWITTER_ACCESS_TOKEN']
twitter_access_token_secret = os.environ['TWITTER_ACCESS_TOKEN_SECRET']
twitter_serarch_string = os.environ['TWITTER_TEXT']

# Service Bus client and queue sender
servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)
sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)

# Send message to service bus queue
def send_single_message(sender, tweet):
    message = ServiceBusMessage(tweet)
    sender.send_messages(message)

# Twitter stream class
class MyStreamListener(Stream):
    def on_status(self, status):

        if (not status.retweeted) and ('RT @ not in status.text'):
            print(status.text)
            send_single_message(sender, status.text)

    def on_error(self, status_code):
        if status_code == 420:
            return False

stream = MyStreamListener(twitter_consumer_key,
                          twitter_consumer_secret,
                          twitter_accesss_token,
                          twitter_access_token_secret)

stream.filter(track=[twitter_serarch_string], languages=["en"])