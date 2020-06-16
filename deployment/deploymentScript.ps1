param(
  [string] [Parameter(Mandatory=$true)] $aksCluster,
  [string] [Parameter(Mandatory=$true)] $aksResourceGroup,
  [string] [Parameter(Mandatory=$true)] $storageAccountName
)

# Create storage queue
az storage queue create --name $storageAccountName --account-name $storageAccountName

# Connect to AKS Cluster
bash -c "curl -sL https://aka.ms/InstallAzureCLIDeb | bash"
bash -c "az login --identity"
bash -c "az aks install-cli"
bash -c "az aks get-credentials --name $aksCluster --resource-group $aksResourceGroup"
bash -c "kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml"
bash -c "kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/mic-exception.yaml"