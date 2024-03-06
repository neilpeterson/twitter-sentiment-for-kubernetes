import os
import json
import time
# from tweepy import Stream
from azure.servicebus import ServiceBusClient, ServiceBusMessage

# Azure Service Bus connection details
CONNECTION_STR = os.environ['SERVICE_BUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICE_BUS_QUEUE_NAME"]

# Service Bus client and queue sender
servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)
sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)

# Send message to service bus queue
def send_single_message(sender, tweet):
    message = ServiceBusMessage(tweet)
    sender.send_messages(message)

# Read MOC Tweet from file
__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
f = open(os.path.join(__location__, 'tweet-body.json'))
data = json.load(f)

# Print MOC tweet and send to Azuer Service Bus Queue
while True:

    for i in data['tweets']:
        print(i['text'])
        send_single_message(sender, i['text'])

    time.sleep(int(os.environ["SCALE_SLEEP_SECONDS"]))