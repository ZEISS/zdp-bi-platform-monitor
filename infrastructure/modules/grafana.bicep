param name string
param location string = resourceGroup().location
param identityId string
// param prometheusUrl string

// var definition = concat('''
//   { 
//     "access": "proxy", 
//     "name": "prometheus", 
//     "type": "prometheus", 
//     "typeLogoUrl": "public/app/plugins/datasource/prometheus/img/prometheus_logo.svg", 
//     "typeName": "Prometheus", 
//     "url": ''', 
//     prometheusUrl, '})')


param admins array = [
  'e86f762c-56cd-470e-bec2-b4b0436068e4' //zospohl
  '12f5ed14-93b6-4f1b-b9b2-cfb05f555de8' //Kush
]

resource grafana 'Microsoft.Dashboard/grafana@2023-09-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}' : {}
    }
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    grafanaMajorVersion: '10'
  }
}

// do not work couse of extenion failure during installation
// resource datasource 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
//   name: 'inlineCLI'
//   location: location
//   kind: 'AzureCLI'
//   properties: {
//     azCliVersion: '2.7.0'
//     retentionInterval: 'PT1H'
//     arguments: '${grafana.name} ${definition}'
//     scriptContent: '''
//       az extension add --name amg
//       az grafana data-source create --name ${grafana.name} --definition ${definition}
//     '''
//   }
// }

resource grafanaAdminRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '22926164-76b3-42b3-bc55-97df8dab3e41'
  scope: resourceGroup()
}

resource grafanaAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for admin in admins: {
  name: guid(resourceGroup().id, admin, grafanaAdminRole.id)
  properties: {
    principalId: admin
    roleDefinitionId: grafanaAdminRole.id
    principalType: 'User'
  }
}]
