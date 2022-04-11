targetScope='resourceGroup'

param org_name string
param org_region string = resourceGroup().location

param org_kv_name string = 'kv-${org_name}'
param org_acr_name string = 'acr${org_name}'
param org_lawks_name string = 'lawks-${org_name}'
param org_afd_name string = 'afd-${org_name}'
param org_afd_endpoint_name string = 'afd-${org_name}'

resource org_afd_resource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: org_afd_name
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource org_acr_resource 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: org_acr_name
  location: org_region
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    anonymousPullEnabled: false
  }
}

resource org_kv_resource 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: org_kv_name
  location: org_region
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
    accessPolicies: [
      {
        tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
        objectId: '1e87ffdc-02a4-4885-a493-05997478c59b'
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Enabled'
  }
}

resource org_lawks_resource 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: org_lawks_name
  location: org_region
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource org_afd_endpoint_resource 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  parent: org_afd_resource
  name: org_afd_endpoint_name
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}
