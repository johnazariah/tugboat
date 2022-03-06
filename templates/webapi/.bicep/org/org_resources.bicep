targetScope = 'resourceGroup'

param org_name string
param org_region string = resourceGroup().location

var _acr = 'acr${org_name}oaks'
var org_acr = substring(_acr, 0, min(45, length(_acr)))

//var org_acr_login_server = '${org_acr}.azurecr.io'
//var org_azurefrontdoor = 'afd-${org_name}'
var org_keyvault = 'kv-${org_name}'
//var org_lawks = 'lawks-${org_name}'

resource orgACR 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: org_acr
  location: org_region
  sku: {
    name: 'Basic'
  }  
  properties: {
    adminUserEnabled: true
  }
}

@description('The login server for the organization-wide Azure Container Registry')
output org_acr_login_server string = orgACR.properties.loginServer

resource orgKV 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: org_keyvault
  location: org_region
  properties: {
    sku:{
      name: 'standard'
      family: 'A'
    }
    tenantId: tenant().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
  }
}

@description('The login server for the organization-wide Azure Container Registry')
output org_keyvault_vaultUri string = orgKV.properties.vaultUri
