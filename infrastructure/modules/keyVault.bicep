param name string
param location string = resourceGroup().location
param principalId string

param admins array = [
  'e86f762c-56cd-470e-bec2-b4b0436068e4' //zospohl
  '12f5ed14-93b6-4f1b-b9b2-cfb05f555de8' //Kush
]

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
  }
}

resource kvSecretOfficer 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  scope: resourceGroup()
}

resource secretOfficer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, kvSecretOfficer.id)
  properties: {
    principalId: principalId
    roleDefinitionId: kvSecretOfficer.id
    principalType: 'ServicePrincipal'
  }
}

resource kvAdminRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: resourceGroup()
}

resource kvAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = [ for admin in admins: {
  name: guid(resourceGroup().id, admin, kvAdminRole.id)
  properties: {
    principalId: admin
    roleDefinitionId: kvAdminRole.id
    principalType: 'User'
  }
}]

output name string = kv.name
