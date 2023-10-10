$region="australiaeast"
$resourceGroupName = "appinsights-monitoring-sample"

az group create --name $resourceGroupName --location $region

az deployment group create `
    --resource-group $resourceGroupName `
    --template-file "basic-app-with-monitoring.bicep" `
    --parameters "basic-app-with-monitoring.bicepparam"