param location string = resourceGroup().location
param storageAccountName string = ''
param logAnalyticsName string = ''
param managedIdentityName string = ''
param grafanaName string = ''
param acrName string = ''
param acaEnvName string = ''
param acaNamePrometheus string = ''
param acaNameExporter string = ''
param acaNameAlertManager string = ''
param acaNameAlertsReceiver string = ''

module storage 'modules/storage.bicep' = {
  name: 'storageAccount'
  params: {
    name: storageAccountName
    location: location
  }
}

module logAnalytics 'modules/logs.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsName
    location: location
  }
}

module identity 'modules/identity.bicep' = {
  name: 'managedIdentity'
  params: {
    name: managedIdentityName
    location: location
  }
}

module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: acrName
    principalId: identity.outputs.principalId
  }
}

module acaEnv 'modules/aca-env.bicep' = {
  name: 'acaEnv'
  params: {
    name: acaEnvName
    location: location
    logAnalyticsName: logAnalytics.outputs.name
    storageAccountName: storage.outputs.name
  }
}

module acaPrometheus 'modules/aca-prometheus.bicep' = {
  name: 'aca-prometheus'
  params: {
    name: acaNamePrometheus
    location: location
    acr: acr.outputs.acrServerName
    environmentId: acaEnv.outputs.envId
    identityId: identity.outputs.id
  }
}

module acaExporter 'modules/aca-exporter.bicep' = {
  name: 'aca-exporter'
  params: {
    name: acaNameExporter
    location: location
    acr: acr.outputs.acrServerName
    environmentId: acaEnv.outputs.envId
    identityId: identity.outputs.id
  }
}

module acaAlertmanager 'modules/aca-alertmanager.bicep' = {
  name: 'aca-alertmanager'
  params: {
    name: acaNameAlertManager
    location: location
    acr: acr.outputs.acrServerName
    environmentId: acaEnv.outputs.envId
    identityId: identity.outputs.id
  }
}

module acaAlertReceiver 'modules/aca_alertsreceiver.bicep' = {
  name: 'aca-alertsreceiver'
  params: {
    name: acaNameAlertsReceiver
    location: location
    acr: acr.outputs.acrServerName
    environmentId: acaEnv.outputs.envId
    identityId: identity.outputs.id
  }
}

module grafana 'modules/grafana.bicep' = {
  name: 'grafana'
  params: {
    name: grafanaName
    location: location
    identityId: identity.outputs.id
    // prometheusUrl: acaPrometheus.outputs.url
  }
}
