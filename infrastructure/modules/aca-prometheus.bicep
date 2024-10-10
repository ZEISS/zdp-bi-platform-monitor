param name string
param location string
param environmentId string
param identityId string
param acr string

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
        allowInsecure: false
        targetPort: 9090
        external: true
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
      volumes: [
        {
          name: 'config'
          storageType: 'AzureFile'
          storageName: 'config'
        }
      ]
      containers: [
        {
          name: 'prometheus'
          image: 'docker.io/ubuntu/prometheus:latest'
          //image: '${acr}/prometheus:latest'
          volumeMounts: [
            {
              volumeName: 'config'
              mountPath: '/etc/prometheus'
              subPath: 'prometheus'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
    }
  }
}

output url string = prometehus.properties.configuration.ingress.fqdn
