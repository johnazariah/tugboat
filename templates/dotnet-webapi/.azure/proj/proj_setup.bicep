targetScope='subscription'

@minLength(3)
@maxLength(16)
@description('Provide the name of the organization this project should belong to')
param org string

@minLength(3)
@maxLength(16)
@description('Provide a name for this project unique within the organization')
param project string

// @description('Provide the region to deploy your organization-wide resources')
// param org_region string = deployment().location

@description('Provide the region to deploy your project-wide resources')
param proj_region string = deployment().location

var org_lc = toLower(org)
var proj_lc = toLower(project)
var proj_resource_group = 'rg-${org_lc}-${proj_lc}-${proj_region}'

resource proj_rg_resource 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: proj_resource_group  
  location: proj_region
  tags: {
    'tugboat-org': org_lc 
    'tugboat-project': proj_lc 
  }
}

module proj_resources './proj_resources.bicep' = {
  name: 'proj_resources'
  params: {
    org_name: org_lc
    proj_name: proj_lc
    proj_region: proj_region
  }
  scope: proj_rg_resource
}
