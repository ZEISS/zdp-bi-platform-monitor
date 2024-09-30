param location string = resourceGroup().location
param storageAccountName string = ''
param logAnalyticsName string = ''
param managedIdentityName string = ''
param acrName string = ''
param acaEnvName string = ''
param acaName string = ''

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

module aca 'modules/aca.bicep' = {
  name: 'aca'
  params: {
    name: acaName
    location: location
    acr: acr.outputs.acrServerName
    environmentId: acaEnv.outputs.envId
    identityId: identity.outputs.id
  }
}
