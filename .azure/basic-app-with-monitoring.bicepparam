using './basic-app-with-monitoring.bicep'

param projectName = 'monitoring'
param environmentName = 'sample'
param logAnalyticsName = 'laws-${projectName}-${environmentName}'
param appInsightsName = 'ai-${projectName}-${environmentName}'
param appServiceSku = 'B1'
param appServicePlanName = 'plan-${projectName}-${environmentName}'
param appServiceName = 'app-${projectName}-${environmentName}'
param appConfigurationName = 'appconf-${projectName}-${environmentName}'

