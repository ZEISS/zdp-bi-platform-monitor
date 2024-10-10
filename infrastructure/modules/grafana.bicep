param name string
param location string = resourceGroup().location
param identityId string

param admins array = [
  'e86f762c-56cd-470e-bec2-b4b0436068e4' //zospohl
  '12f5ed14-93b6-4f1b-b9b2-cfb05f555de8' //Kush
]

// param viewers array [

// ]

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

// resource grafanaViewerRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
//   name: '60921a7e-fef1-4a43-9b16-a26c52ad4769'
//   scope: resourceGroup()
// }

// resource grafanaUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for viewer in viewers: {
//   name: guid(resourceGroup().id, viewer, grafanaUserRole.id)
//   properties: {
//     principalId: viewer
//     roleDefinitionId: grafanaAdminRole.id
//     principalType: 'User'
//   }
// }]
