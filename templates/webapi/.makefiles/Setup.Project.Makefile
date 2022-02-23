# These commands are to be used to do a one-time set up of the project-specific resources
proj-cleanup:
	- az group delete --name $(proj_resource_group) --yes
	@echo Completed cleaning up project resources

proj-setup : proj-setup-rg proj-setup-aks
	@echo Completed setting up project resources

proj-setup-rg :
	@echo Starting to set up project resource group [$(proj_resource_group)]
	- az group create\
		--name $(proj_resource_group)\
		--location $(proj_region)
	@echo

proj-setup-aks :
	@echo Starting to set up project AKS cluster [$(proj_cluster)]
	- az aks create\
		--name $(proj_cluster)\
		--resource-group $(proj_resource_group)\
		--location $(proj_region)\
		--node-vm-size Standard_DS2_v5\
		--node-count 2\
		--workspace-resource-id /subscriptions/$(sub)/resourcegroups/$(org_resource_group)/providers/microsoft.operationalinsights/workspaces/$(org_lawks)\
		--attach-acr $(org_acr)\
		--enable-addons monitoring\
		--enable-addons ingress-appgw\
		--appgw-name $(proj_appgateway)\
		--appgw-subnet-cidr "10.2.0.0/16"\
		--enable-managed-identity\
		--generate-ssh-keys
	@echo

proj-prepare-aks : proj-register-provider proj-install-cli proj-get-credentials proj-export-config

proj-register-provider :
	@echo Registering OperationsManagement and OperationalInsights
	- az provider register --namespace Microsoft.OperationsManagement
	- az provider register --namespace Microsoft.OperationalInsights
	@echo

proj-install-cli :
	- az aks install-cli

proj-get-credentials :
	- az aks get-credentials --resource-group $(proj_resource_group) --name $(proj_cluster)

proj-export-config :
	- cp /root/.kube/config .aks_kube_config