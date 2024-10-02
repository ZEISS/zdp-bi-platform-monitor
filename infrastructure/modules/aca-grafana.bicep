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
        targetPort: 3000
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
      volumes: [
        {
          name: 'config'
          storageType: 'AzureFile'
          storageName: 'config'
        }
      ]
      containers: [
        {
          name: 'grafana'
          image: 'grafana/grafana-oss:latest'
          volumeMounts: [
            {
              volumeName: 'config'
              mountPath: '/var/lib/'
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
