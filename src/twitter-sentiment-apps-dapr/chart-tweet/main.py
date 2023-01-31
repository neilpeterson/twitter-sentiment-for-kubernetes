from flask import Flask, request, render_template
import os
import pydocumentdb.document_client as document_client
import pygal
from pygal.style import BlueStyle

# CosmosDB connection and DB settings
cosmos_db_endpoint = os.environ['COSMOS_DB_ENDPOINT']
cosmos_db_masterkey = os.environ['COSMOS_DB_MASTERKEY']
cosmos_db_database = os.environ['COSMOS_DB_DATABASE']
cosmos_db_collection = os.environ['COSMOS_DB_COLLECTION']

# Set chart title
if "CHART_LABEL" in os.environ:
    chart_title = "Tweets about " + chart_label
else:
    chart_title = "Tweet Sentiment"

# Initialize the Python DocumentDB client
client = document_client.DocumentClient(cosmos_db_endpoint, {'masterKey': cosmos_db_masterkey})

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():

    # Return data from Cosmos DB
    db = next((data for data in client.ReadDatabases() if data['id'] == cosmos_db_database))
    coll = next((coll for coll in client.ReadCollections(db['_self']) if coll['id'] == cosmos_db_collection))
    docs = client.ReadDocuments(coll['_self'])

    positive = 0
    neutral = 0
    negative = 0
    mixed = 0

    for doc in docs:
        if doc["value"]["tweets"]["sentiment"] == 'positive':
            positive += 1
        elif (doc["value"]["tweets"]["sentiment"] == 'neutral'):
            neutral += 1
        elif doc["value"]["tweets"]["sentiment"] == 'negative':
            negative +=1
        elif doc["value"]["tweets"]["sentiment"] == 'mixed':
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
