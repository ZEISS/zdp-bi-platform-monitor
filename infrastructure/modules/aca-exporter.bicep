param name string
param location string
param environmentId string
param identityId string
param acr string

resource exporter 'Microsoft.App/containerApps@2024-03-01' = {
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
        allowInsecure: false
        targetPort: 9080
        external: true
        clientCertificateMode: 'ignore'
      }
      registries: [
        {
          identity: identityId
          server: acr
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
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}
