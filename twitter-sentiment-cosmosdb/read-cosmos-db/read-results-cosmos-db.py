import os
import pydocumentdb
import pydocumentdb.document_client as document_client

# CosmosDB connection and DB settings
COSMOS_DB_ENDPOINT = os.environ['COSMOS_DB_ENDPOINT']
COSMOS_DB_MASTERKEY = os.environ['COSMOS_DB_MASTERKEY']
COSMOS_DB_DATABASE = os.environ['COSMOS_DB_DATABASE']
COSMOS_DB_COLLECTION = os.environ['COSMOS_DB_COLLECTION']

# Initialize the Python DocumentDB client
client = document_client.DocumentClient(COSMOS_DB_ENDPOINT, {'masterKey': COSMOS_DB_MASTERKEY})

# Return data from Cosmos DB
db = next((data for data in client.ReadDatabases() if data['id'] == COSMOS_DB_DATABASE))
coll = next((coll for coll in client.ReadCollections(db['_self']) if coll['id'] == COSMOS_DB_COLLECTION))
docs = client.ReadDocuments(coll['_self'])

i = 1

for doc in docs:
    print(doc['message'] + ' ====== Sentiment ' + str(doc['sentiment']))
    i += 1
    
print(str(i))