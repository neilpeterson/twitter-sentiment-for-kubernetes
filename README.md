# Twitter Sentiment engine

Collects tweets, gets sentiments of tweets, stores, and visualizes results.

![application architecture](/images/app.png)

## Prerequisites

You will need a Twitter account and credentials for authentication with Twitter APIs. You can sign up for a Twitter developer account at https://developer.twitter.com/ .

- TWITTER_CONSUMER_KEY
- TWITTER_CONSUMER_SECRET
- TWITTER_ACCESS_TOKEN
- TWITTER_ACCESS_TOKEN_SECRET

You also need an Azure account, the Azure CLI installed and authenticated, and a pre-created Kubernetes cluster.

## Quickstart

Clone this repo to your development system.

```
git clone https://github.com/neilpeterson/twitter-sentiment-for-kubernetes.git
```

Create environment variables to hold your Twitter developer account credentials.

```
export TWITTER_CONSUMER_KEY=<>
export TWITTER_CONSUMER_SECRET=<>
export TWITTER_ACCESS_TOKEN=<>
export TWITTER_ACCESS_TOKEN_SECRET=<>
```

Create an environment variable to hold the desired Twitter search term.

```
export TWITTER_TEXT=Seattle
```

Run the quick start script.

```
sh deployment/quickstart/build-twitter-sentiment-kubernetes.sh
```

Once complete, the needed Azure services are deployed, and several files have been created to help bootstrap the Tweet Facotry application. Each file is detailed below.

## Bootstrap files

| File | Description |
|----|----|
| twitter-sentiment-kubernetes-manifest.yml | Deploy the application to a Kubernetes cluster. |
| docker-compose.yml | Run the application using Docker Compose. |
| twitter-sentiment-environment-variables.sh | Script to create environment variables for performing local tests etc.. |
| values.yml | Values file to be used with included Helm chart. |

## Run the Application

The included script not only creates the required Azure resource it also creates a pre-populated Kubernetes manifest file that can be used to start the application. The manifest file is located in the directory from which the script was run.

Note: Several Azure connection strings and keys are stored in the pre-created manifest files.

Deploy the Kubernetes manifest.

```
kubectl apply -f twitter-sentiment-kubernetes-manifest.yml
```

Output:

```
deployment "process-tweet" created
deployment "get-tweet" created
deployment "chart-tweet" created
service "chart-tweet" created
```

The Chart Tweet service can take some time to complete. To watch progress, run the following.

```
kubectl get service -w
```

Once a public IP address has been returned, browse to this IP address to see the returned sentiment results.

## Caution

Once the application starts, tweets are immediately captured, stored in the Azure Queue, and processed. While the application is running, it will incur an Azure cost. As the number of returned tweets increases, so does the Azure spend.

To stop and remove the application, run the following.

```
kubectl delete -f twitter-sentiment-kubernetes-manifest.yml
```