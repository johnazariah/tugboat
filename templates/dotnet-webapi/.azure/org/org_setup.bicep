targetScope='subscription'

@minLength(3)
@maxLength(16)
@description('Provide a globally unique name of your organization')
param org string

@description('Provide the region to deploy your organization-wide resources')
param org_region string = deployment().location

var org_lc = toLower(org)
var org_resource_group = 'rg-${org_lc}-tgbt-${org_region}'

resource org_rg_resource 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: org_resource_group  
  location: org_region
  tags: {
    'tugboat-org': org 
  }
}

module org_resources './org_resources.bicep' = {
  name: 'org_resources'
  params: {
    org_name: org_lc
    org_region: org_rg_resource.location
  }
  scope: org_rg_resource
}
