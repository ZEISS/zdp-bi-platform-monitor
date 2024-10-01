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
        targetPort: 9093
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
          name: 'alertmanager'
          image: 'prom/alertmanager:latest'
          volumeMounts: [
            {
              volumeName: 'config'
              mountPath: '/etc/'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
        {
          name: 'alerts-receiver'
          image: '${acr}/alerts_receiver:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}
