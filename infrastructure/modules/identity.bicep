param name string
param location string = resourceGroup().location

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
    name: name
    location: location
}

output id string = identity.id
output principalId string = identity.properties.principalId
