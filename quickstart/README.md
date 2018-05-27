# Twitter sentiment Azure toy - quickstart

## Prerequisites

You a Twitter account and credentials for authentication with Twitter APIs. You can sign up for a Twitter developer account at https://developer.twitter.com/ .

- TWITTER_CONSUMER_KEY
- TWITTER_CONSUMER_SECRET
- TWITTER_ACCESS_TOKEN
- TWITTER_ACCESS_TOKEN_SECRET

You also need an Azure account and the Azure CLI installed on your development system.

## Quickstart

Clone this repo to your development system.

```
git clone https://github.com/neilpeterson/twitter-sentiment-quick-start.git
```

Open the `build-twitter-sentiment-kubernetes.sh file. In this file, update the Twitter key, secret, and tokens, and also the search term.

```
#!/bin/bash

# Twitter API Endpoint and Credentials - this is not automated so must be specified.
TWITTER_CONSUMER_KEY=<replace>
TWITTER_CONSUMER_SECRET=<replace>
TWITTER_ACCESS_TOKEN=<replace>
TWITTER_ACCESS_TOKEN_SECRET=<replace>

# Twitter search term - used to filter returned tweets.
TWITTER_TEXT=Seattle
```

when finished, save and close the file.

Run the script.

```
sh build-twitter-sentiment-kubernetes.sh
```

Once complete, the needed Azure service are deployed, and several files have been created. These files are pre-populated with the necessary values and can be used to deploy the application into a Kubernetes cluster, Docker Swarm, as well some other helper files are created. Each file is detailed in the next section of this document.

## Bootstrap files

| File | Description |
|----|----|
| twitter-sentiment-kubernetes-manifest.yml | Deploy the application to a Kubernetes cluster. |
| docker-compose.yml | Run the application using Docker Compose. |
| twitter-sentiment-environment-variables.sh | Script to create environment variables for performing local tests etc... |
| tmux.sh | Configures a shell environment for application / scale demos. |
| twitter-sentiment-kubernetes-crd.yml | Configures a Kubernetes cluster with a custom resource definition / operator for scaling a pod based on Azure storage queue length. |

## Run the Application

The included script not only creates the required Azure resource, it also creates a pre-populated Kubernetes manifest file that can be used to start the application. The manifest file is located in the directory from which the script was run.

Note: Several Azure connection strings and keys are stored in the pre-created manifest files. Consider using Kubernetes secrets when performing similar operations with production applications.

Run the manifest file.

```
twitter-sentiment-kubernetes-manifest.yml
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

Once a public IP address has been returned, browse to this IP address to see the retuned sentiment results.

## Caution

Once the application starts, tweets are immediately captured, stored in the Azure Queue, and processed. While the application is running, it will incur an Azure cost. As the number of returned tweets increases, so does the Azure spend.


