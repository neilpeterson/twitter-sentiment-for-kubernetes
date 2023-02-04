# Standard Deployment

This doc assumes that the local terminal environment is Powershell.

## Azure Infrastructure

1. Gather Twitter API Keys and secrets.
2. Deploy Azure Infrastructure. During this process, enter Twitter API keys and secrets.

```
az group create --name twitter-showtime-001 --location eastus  
az deployment group create --template-file ./deployment/bicep/azure-infra/main.bicep --resource-group twitter-showtime-001
```

## Local env setup

Create the following environment variables for consumption by the applications.

```
$env:TWITTER_CONSUMER_KEY = ""
$env:TWITTER_CONSUMER_SECRET = ""
$env:TWITTER_ACCESS_TOKEN = ""
$env:TWITTER_ACCESS_TOKEN_SECRET = ""
$env:AZURE_ANALYTICS_URI = ""
$env:AZURE_ANALYTICS_KEY = ""
$env:COSMOS_DB_ENDPOINT = ""
$env:COSMOS_DB_MASTERKEY = ""
$env:COSMOS_DB_DATABASE = "twitter"
$env:COSMOS_DB_COLLECTION = "twitter"
$env:SERVICE_BUS_CONNECTION_STR = ""
$env:SERVICE_BUS_QUEUE_NAME = "twitter"
$env:TWITTER_TEXT = "Seattle"
```

Activate a Python virtual environment

```
/Users/neilpeterson/Documents/code/python-virtual-env/twitter-sentiment/bin/Activate.ps1
```

Install pacakages if necisary.

```
Update later
```

## Run Get Tweets Application

```
python ./src/twitter-sentiment-apps/get-tweet/get-tweet.py
```

```
@Sophia_Nyx Saving private Ryan, Forrest Gump, Road to perdition, the green mile, Apollo 13, Sleepless in Seattle,… https://t.co/xirKFG8cHB
@SoundersFC @AlAhly I warned you about the luck of Ahly, unreal, and the FIFA assigned a blind referee for this mat… https://t.co/d3r1btJyxs
@habeshashooter You want civil war but you’re tweeting this from Starbucks in Seattle. Ere pls😆
```

## Run Process Tweets Application

```
python ./src/twitter-sentiment-apps/process-tweet/process-tweet.py
```

```
RT @photoJDL: Todays flight: @delta 197 from Seattle to Seoul. Our bird is N415DX, a ~3m old A339N. https://t.co/LDzaERF3EJ
{"documents":[{"id":"apex-demo","sentiment":"neutral","confidenceScores":{"positive":0.04,"neutral":0.95,"negative":0.01},"sentences":[{"sentiment":"neutral","confidenceScores":{"positive":0.0,"neutral":0.99,"negative":0.0},"offset":0,"length":63,"text":"RT @photoJDL: Todays flight: @delta 197 from Seattle to Seoul. "},{"sentiment":"neutral","confidenceScores":{"positive":0.0,"neutral":1.0,"negative":0.0},"offset":63,"length":37,"text":"Our bird is N415DX, a ~3m old A339N. "},{"sentiment":"neutral","confidenceScores":{"positive":0.11,"neutral":0.87,"negative":0.02},"offset":100,"length":23,"text":"https://t.co/LDzaERF3EJ"}],"warnings":[]}],"errors":[],"modelVersion":"2022-11-01"}
neutral
RT @hexeract01: People of Seattle
#leicaq #seattle https://t.co/qrHnQr4gqn
{"documents":[{"id":"apex-demo","sentiment":"neutral","confidenceScores":{"positive":0.05,"neutral":0.94,"negative":0.01},"sentences":[{"sentiment":"neutral","confidenceScores":{"positive":0.05,"neutral":0.94,"negative":0.01},"offset":0,"length":74,"text":"RT @hexeract01: People of Seattle #leicaq #seattle https://t.co/qrHnQr4gqn"}],"warnings":[]}],"errors":[],"modelVersion":"2022-11-01"}
neutral
```

## Run Chart Tweets Applicaton

```
python ./src/twitter-sentiment-apps/chart-tweet/main.py   
```

```
 * Serving Flask app 'main'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
```