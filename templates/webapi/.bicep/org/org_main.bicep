targetScope = 'subscription'

@minLength(3)
@maxLength(16)
@description('Provide a globally unique name of your organization')
param org string

@description('Provide the region to deploy your organization-wide resources')
param org_region string = deployment().location

var org_lc = toLower(org)
var org_resource_group = 'rg-${org_lc}-oaks-${org_region}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: org_resource_group  
  location: org_region
}

module orgModule './org_resources.bicep' = {
  name: 'OrgModule'
  params: {
    org_name: org_lc
    org_region: resourceGroup.location
  }
  scope: resourceGroup
}
