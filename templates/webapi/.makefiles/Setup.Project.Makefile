# These commands are to be used to do a one-time set up of the project-specific resources
proj-cleanup:
	- az group delete --name $(proj_resource_group) --yes
	@echo Completed cleaning up project resources

proj-setup : proj-setup-rg proj-setup-aks proj-setup-frontdoor
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

proj-setup-frontdoor :
	@echo Starting to set up project Azure Front Door profile
	ENDPOINT_NAME := $(org)
	ORIGIN_GROUP_NAME := $(proj_name)
	ORIGIN_NAME := $(proj_name)
	ROUTE_NAME := $(proj_name)
	AGW_RESOURCE_ID := $(
		az aks show \
			--name $(proj_cluster) \
			--resource-group $(proj_resource_group) \
			--query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId" \
			--output tsv
	)

	PIP_RESOURCE_ID := $(
		az network application-gateway show \
			--ids $(AGW_RESOURCE_ID) \
			--query "frontendIpConfigurations[?publicIpAddress.id != '' && type == 'Microsoft.Network/applicationGateways/frontendIPConfigurations'] | [0].publicIpAddress.id" \
			--output tsv
	)

	PIP_IP := $(
		az network public-ip show \
			--ids $(PIP_RESOURCE_ID) \
			--query "ipAddress" \
			--output tsv
	)

	az afd endpoint create \
		--profile-name $(org_azurefrontdoor) \
		--resource-group $(org_resource_group) \
		--enabled-state Enabled \
		--endpoint-name $(ENDPOINT_NAME) \
		--origin-response-timeout-seconds 60

	az afd origin-group create \
		--profile-name $(org_azurefrontdoor) \
		--resource-group $(org_resource_group) \
		--origin-group-name $(ORIGIN_GROUP_NAME) \
		--probe-path "/" \
		--probe-protocol NotSet \
		--probe-request-type NotSet \
		--sample-size 4 \
		--successful-samples-required 3 \
		--additional-latency-in-milliseconds 50

	az afd origin create \
		--profile-name $(org_azurefrontdoor) \
		--resource-group $(org_resource_group) \
		--origin-group-name $(ORIGIN_GROUP_NAME) \
		--origin-name $(ORIGIN_NAME) \
		--enabled-state Enabled \
		--host-name $(PIP_IP) \
		--http-port 80 \
		--https-port 443 \
		--priority 1 \
		--weight 1000

	az afd route create \
		--profile-name $(org_azurefrontdoor) \
		--resource-group $(org_resource_group) \
		--endpoint-name $(ENDPOINT_NAME) \
		--route-name $(ROUTE_NAME) \
		--https-redirect Enabled \
		--origin-group $(ORIGIN_GROUP_NAME) \
		--https-redirect Enabled \
		--supported-protocols Https \
		--patterns-to-match "/$(proj_name)/*" \
		--origin-path "/$(proj_name)/" \
		--link-to-default-domain Disabled \
		--forwarding-protocol HttpOnly
	@echo

proj-prepare-aks : proj-register-provider proj-install-cli proj-get-credentials proj-export-config

proj-register-provider :
	@echo Registering OperationsManagement, OperationalInsights and Cdn
	- az provider register --namespace Microsoft.OperationsManagement
	- az provider register --namespace Microsoft.OperationalInsights
	- az provider register --namespace Microsoft.Cdn
	@echo

proj-install-cli :
	- az aks install-cli

proj-get-credentials :
	- az aks get-credentials --resource-group $(proj_resource_group) --name $(proj_cluster)

proj-export-config :
	- cp /root/.kube/config .aks_kube_config