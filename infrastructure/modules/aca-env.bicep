param name string
param location string
param logAnalyticsName string
param storageAccountName string
// param subnetId string

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name:storageAccountName
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource aca_env 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    // vnetConfiguration: {
    //   infrastructureSubnetId: subnetId
    //   internal: true
    // }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

resource aca_env_storage 'Microsoft.App/managedEnvironments/storages@2024-03-01' = {
  name: 'config'
  parent: aca_env
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountName: storage.name
      accountKey: storage.listKeys().keys[1].value
      shareName: 'config'
    }
  }
}

output envId string = aca_env.id
output defaultDomain string = aca_env.properties.defaultDomain
output staticIp string = aca_env.properties.staticIp
