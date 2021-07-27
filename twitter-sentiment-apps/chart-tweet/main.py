from flask import Flask, request, render_template
import os
import pydocumentdb.document_client as document_client
import pygal
from pygal.style import BlueStyle

# CosmosDB connection and DB settings
COSMOS_DB_ENDPOINT = os.environ['COSMOS_DB_ENDPOINT']
COSMOS_DB_MASTERKEY = os.environ['COSMOS_DB_MASTERKEY']
COSMOS_DB_DATABASE = os.environ['COSMOS_DB_DATABASE']
COSMOS_DB_COLLECTION = os.environ['COSMOS_DB_COLLECTION']

# Chart label - static for now, will update to somethign dynamic
CHART_LABEL = os.environ['CHART_LABEL']

# Set chart title
if "CHART_LABEL" in os.environ:
    chart_title = "Tweets about " + CHART_LABEL
else:
    chart_title = "Tweet Sentiment"

# Initialize the Python DocumentDB client
client = document_client.DocumentClient(COSMOS_DB_ENDPOINT, {'masterKey': COSMOS_DB_MASTERKEY})

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():

    # Return data from Cosmos DB
    db = next((data for data in client.ReadDatabases() if data['id'] == COSMOS_DB_DATABASE))
    coll = next((coll for coll in client.ReadCollections(db['_self']) if coll['id'] == COSMOS_DB_COLLECTION))
    docs = client.ReadDocuments(coll['_self'])

    positive = 0
    neutral = 0
    negative = 0
    mixed = 0

    for doc in docs:
        if doc['sentiment'] == 'positive':
            positive += 1
        elif (doc['sentiment'] == 'neutral'):
            neutral += 1
        elif doc['sentiment'] == 'negative':
            negative +=1
        elif doc['sentiment'] == 'mixed':
            mixed +=1

    pie_chart = pygal.Pie(style=BlueStyle, print_values=True)
    pie_chart.title = chart_title
    pie_chart.add('Positive',positive)
    pie_chart.add('Neutral',neutral)
    pie_chart.add('Negative', negative)
    pie_chart.add('Mixed', mixed)
    graph = pie_chart.render_data_uri()
    return render_template("index.html", graph_data = graph)

if __name__ == "__main__":
    app.run()
