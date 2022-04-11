targetScope='resourceGroup'

param org_name string
param proj_name string
param proj_region string = resourceGroup().location
param proj_storage_name string = 'stg${org_name}${proj_name}'

resource proj_storage_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: proj_storage_name
  location: proj_region
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_0'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}
