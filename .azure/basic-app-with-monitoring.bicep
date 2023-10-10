param location string = resourceGroup().location

param projectName string
param environmentName string = 'test'

@description('Resource tags for organizing / cost monitoring')
var tags = {
  project: projectName
  environment: environmentName
}

param logAnalyticsName string
param appInsightsName string

param appServiceSku string = 'B1'
param appServicePlanName string
param appServiceName string

param appConfigurationName string

param linuxFxVersion string = 'DOTNETCORE|7.0'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    DisableLocalAuth: true
  }
}

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2020-06-01' = {
  name: appConfigurationName
  location: location
  sku: {
    name: 'Free'
  }
  tags: tags
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  tags: tags
  sku: {
    name: appServiceSku
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'APPINSIGHTS_PROFILERFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name: 'APPINSIGHTS_SNAPSHOTFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name: 'APPLICATIONINSIGHTS_ENABLESQLQUERYCOLLECTION'
          value: 'disabled'
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'DiagnosticServices_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'DISABLE_APPINSIGHTS_SDK'
          value: 'disabled'
        }
        {
          name: 'IGNORE_APPINSIGHTS_SDK'
          value: 'disabled'
        }
        {
          name: 'InstrumentationEngine_EXTENSION_VERSION'
          value: 'disabled'
        }
        {
          name: 'SnapshotDebugger_EXTENSION_VERSION'
          value: 'disabled'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_BaseExtensions'
          value: 'disabled'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_PreemptSdk'
          value: 'disabled'
        }
      ]
    }
  }
}

// get IDs using:
//
// az role definition list --name "Monitoring Metrics Publisher" --output json --query '[].{roleName:roleName, description:description, name:name}'
//

// Monitoring Metrics Publisher
var monitoringMetricsPublisherRoleName = '3913510d-42f4-4e42-8a64-420c390055eb'

resource monitoringMetricsPublisherRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(monitoringMetricsPublisherRoleName, appInsights.id)
  scope: appInsights
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringMetricsPublisherRoleName)
    principalId: appService.identity.principalId
  }
}

output appServiceEndpointUri string = appService.properties.defaultHostName
