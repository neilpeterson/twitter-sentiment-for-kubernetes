import json
import os
import requests
import random
from dapr.ext.grpc import App, BindingRequest
from dapr.clients import DaprClient
from random import randint

app = App()

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

# Register Dapr binding
@app.binding('twitter-servicebus')
def binding(request: BindingRequest):
    print(request.text(), flush=True)
    returned_sentiment = analytics(str(request.text()))

    payload_store = {
        "tweets": {"tweet": request.text(), "sentiment": returned_sentiment}
    }

    # Save state
    with DaprClient() as d:
        storeName = 'twitter-state'
        d.save_state(store_name=storeName, key=str(
            randint(1, 1000)), value=json.dumps(payload_store))

if __name__ == "__main__":
    app.run(3000)  # run on the server
