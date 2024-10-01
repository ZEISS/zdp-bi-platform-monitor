param name string
param location string = resourceGroup().location
param principalId string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
}

resource acrPullRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  scope: subscription()
}

resource acrPushRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '8311e382-0749-4cb8-b61a-304f252e45ec'
  scope: subscription()
}

resource arcPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, acrPullRole.id)
  properties: {
    principalId: principalId
    roleDefinitionId: acrPullRole.id
    principalType: 'ServicePrincipal'
  }
}

resource arcPush 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, '53d5a3a0-caa5-4c80-b3c6-8b04793edb60', acrPushRole.id)
  properties: {
    principalId: '53d5a3a0-caa5-4c80-b3c6-8b04793edb60'
    roleDefinitionId: acrPushRole.id
    principalType: 'ServicePrincipal'
  }
}

output acrServerName string = acr.properties.loginServer
