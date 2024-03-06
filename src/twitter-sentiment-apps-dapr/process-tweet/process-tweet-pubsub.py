import json
import os
import requests
from cloudevents.http import from_http
from dapr.clients import DaprClient
from flask import Flask, request, jsonify

app = Flask(__name__)
app_port = os.getenv('APP_PORT', '5001')
pubsub_name = 'twiter-servicebus'
pubsub_topic = 'tweet-body'

# Azure Analytics
azure_analytics_uri = os.environ['AZURE_ANALYTICS_URI']
azure_analytics_uri = azure_analytics_uri + "/text/analytics/v3.0/sentiment"
azure_analytics_key = os.environ['AZURE_ANALYTICS_KEY']

# Get sentiment
def analytics(text):
    headers = {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': azure_analytics_key,
    }

    payload = {
        "documents": [
            {
                "language": "en",
                "id": "apex-demo",
                "text": text
            }
        ]
    }

    r = requests.post(azure_analytics_uri,
                      data=json.dumps(payload), headers=headers)

    try:
        return json.loads(r.text)['documents'][0]['sentiment']
    except:
        print("Analytics error.")

# Register Dapr pub/sub subscriptions
@app.route('/dapr/subscribe', methods=['GET'])
def subscribe():
    subscriptions = [{
        'pubsubname': pubsub_name,
        'topic': pubsub_topic,
        'route': pubsub_topic
    }]
    print('Dapr pub/sub is subscribed to: ' + json.dumps(subscriptions))
    return jsonify(subscriptions)

# Dapr subscription in /dapr/subscribe sets up this route
@app.route('/' + pubsub_topic, methods=['POST'])
def orders_subscriber():
    event = from_http(request.headers, request.get_data())

    # Get Tweet and format for state
    returned_sentiment = analytics(str(event.data['tweet']))
    # print(returned_sentiment)
    payload_store = {
        "tweets": {"tweet": event.data['tweet'], "sentiment": returned_sentiment}
    }

    # Save state
    with DaprClient() as d:
        storeName = 'twitter-state'
        d.save_state(store_name=storeName,
                     key=event['id'], value=json.dumps(payload_store))

    return json.dumps({'success': True}), 200, {
        'ContentType': 'application/json'}

app.run(port=app_port)