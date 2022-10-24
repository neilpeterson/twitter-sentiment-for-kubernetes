import os
import json
import random
import sys
from azure.servicebus import ServiceBusClient, ServiceBusMessage

# Azure Service Bus connection details
CONNECTION_STR = os.environ['SERVICE_BUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICE_BUS_QUEUE_NAME"]

# Service Bus client and queue sender
servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)
sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)

# Send multi to service bus queue
def send_multi_message(sender, message):
    sender.send_messages(message)

def build_list(count):
    messages = []

    messagelist = ["Pizza is good","I hate pizza","Pizza is ok"]

    for i in range(0, int(sys.argv[1])):
        messages.append(ServiceBusMessage(random.choice(messagelist)))

    return messages

messages = build_list(20)
send_multi_message(sender,messages)

