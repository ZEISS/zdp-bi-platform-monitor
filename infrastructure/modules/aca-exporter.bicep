param name string
param location string
param environmentId string
param identityId string
param acr string
param keyVaultName string

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' existing = {
  name: 'esb-subscription-key-exporter'
  parent: kv
}

resource prometehus 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}' : {}
    }
  } 
  properties: {
    environmentId: environmentId
    workloadProfileName: 'Consumption'
    configuration: {
      ingress: {
        targetPort: 9080
        external: true
        allowInsecure: true
      }
      registries: [
        {
          identity: identityId
          server: acr
        }
      ]
      secrets: [
        {
          name: 'esb-subscription-key'
          identity: identityId
          keyVaultUrl: secret.properties.secretUri
        }
      ]
    }
    template: {
      scale: {
        maxReplicas: 1
        minReplicas: 1
      }
      containers: [
        {
          name: 'exporter'
          image: '${acr}/exporter:latest'
          env: [
            {
              name: 'esb-subscription-key'
              secretRef: 'esb-subscription-key'
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}

output url string = prometehus.properties.configuration.ingress.fqdn
