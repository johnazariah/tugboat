# These commands are to be used to do a one-time set up of the project-specific resources
proj-cleanup:
	- az group delete --name $(proj_resource_group) --yes
	@echo Completed cleaning up project resources

proj-setup :	org-setup \
				proj-setup-rg \
				proj-setup-stg \
				proj-setup-aks \
				proj-setup-frontdoor \
				proj-setup-awg-nsgs
	@echo Completed setting up project resources

proj-setup-rg :
	@echo Starting to set up project resource group [$(proj_resource_group)]
	- az group create\
		--name $(proj_resource_group)\
		--location $(proj_region)\
		--tags tugboat-org=$(org_name) tugboat-proj=$(proj_name)
	@echo

proj-setup-stg : proj-setup-rg
	@echo Starting to set up project storage account [$(proj_storage)]
	- az storage account create\
		--name $(proj_storage)\
		--resource-group $(proj_resource_group)\
		--kind StorageV2
	@echo

proj-setup-aks : acr_id   = $(shell az acr show --name $(org_acr) --resource-group $(org_resource_group) --query "id" --output tsv)
proj-setup-aks : lawks_id = $(shell az monitor log-analytics workspace show --workspace-name $(org_lawks) --resource-group $(org_resource_group) --query "id" --output tsv)
proj-setup-aks :
	@echo Starting to set up project AKS cluster [$(proj_cluster)]
	@echo
	@echo Will connect cluster $(proj_cluster) to ACR $(acr_id), \
		LA Workspace $(lawks_id)

	- az aks create\
		--name $(proj_cluster)\
		--resource-group $(proj_resource_group)\
		--location $(proj_region)\
		--enable-aad\
		--enable-azure-rbac\
		--node-vm-size standard_d2s_v5\
		--node-count 3\
		--min-count 2 --max-count 5 --enable-cluster-autoscaler\
		--network-plugin azure\
		--enable-managed-identity\
		--enable-addons monitoring,ingress-appgw\
		--workspace-resource-id $(lawks_id)\
		--appgw-name $(proj_appgateway) --appgw-subnet-cidr "10.225.0.0/16"\
		--attach-acr $(acr_id)\
		--generate-ssh-keys
	@echo
# --appgw-name $(proj_appgateway) --appgw-subnet-cidr "10.2.0.0/16"

proj-setup-frontdoor : agw_resource_id = $(shell az aks show --name $(proj_cluster) --resource-group $(proj_resource_group) --query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId" --output tsv )
proj-setup-frontdoor : pip_resource_id = $(shell az network application-gateway show --ids $(agw_resource_id) --query "frontendIpConfigurations[?publicIpAddress.id != '' && type == 'Microsoft.Network/applicationGateways/frontendIPConfigurations'] | [0].publicIpAddress.id" --output tsv)
proj-setup-frontdoor : pip_ip          = $(shell az network public-ip show --ids $(pip_resource_id) --query "ipAddress" --output tsv)
proj-setup-frontdoor : proj-setup-aks
	@echo Starting to set up project Azure Front Door profile
	@echo
	@echo Retrieved AGW Id $(agw_resource_id), \
		PIP Id $(pip_resource_id) \
		and PIP IP $(pip_ip)

	- az afd origin-group create \
		--profile-name $(org_azurefrontdoor) \
		--resource-group $(org_resource_group) \
		--origin-group-name $(proj_name) \
		--probe-path "/" \
		--probe-protocol NotSet \
		--probe-request-type NotSet \
		--sample-size 4 \
		--successful-samples-required 3 \
		--additional-latency-in-milliseconds 50

	- az afd origin create \
		--profile-name $(org_azurefrontdoor) \
		--resource-group $(org_resource_group) \
		--origin-group-name $(proj_name) \
		--origin-name $(proj_name) \
		--enabled-state Enabled \
		--host-name $(pip_ip) \
		--http-port 80 \
		--https-port 443 \
		--priority 1 \
		--weight 1000

	- az afd route create \
		--profile-name $(org_azurefrontdoor) \
		--resource-group $(org_resource_group) \
		--endpoint-name $(org_azurefrontdoor) \
		--route-name $(proj_name) \
		--https-redirect Enabled \
		--origin-group $(proj_name) \
		--https-redirect Enabled \
		--supported-protocols Http Https \
		--patterns-to-match "/$(project-lc)/*" \
		--origin-path "/$(project-lc)/" \
		--link-to-default-domain Disabled \
		--forwarding-protocol HttpOnly
	@echo

proj-setup-awg-nsgs : mc_rg = $(shell az aks show -g $(proj_resource_group) -n $(proj_cluster) --query nodeResourceGroup --output tsv)
proj-setup-awg-nsgs : proj-setup-aks
	- az network nsg create \
		--resource-group $(mc_rg) \
		--name $(proj_agic_nsg_name) \
		--location australiaeast

	# AllowGatewayManagerInbound
	- az network nsg rule create \
		--name AllowGatewayManagerInbound \
		--direction Inbound \
		--resource-group $(mc_rg) \
		--nsg-name $(proj_agic_nsg_name) \
		--priority 300 \
		--destination-port-ranges 65200-65535 \
		--protocol TCP \
		--source-address-prefixes GatewayManager \
		--destination-address-prefixes "*" \
		--access Allow

	# AllowAzureFrontDoor.BackendInbound
	- az network nsg rule create \
		--name AllowAzureFrontDoor.Backend \
		--direction Inbound \
		--resource-group $(mc_rg) \
		--nsg-name $(proj_agic_nsg_name) \
		--priority 200 \
		--destination-port-ranges 443 80 \
		--protocol TCP \
		--source-address-prefixes AzureFrontDoor.Backend \
		--destination-address-prefixes VirtualNetwork \
		--access Allow

proj-prepare-aks : 	proj-acr-login \
					proj-register-provider \
					proj-install-cli \
					proj-get-credentials \
					proj-export-config \
					k8s-set-default-namespace


proj-acr-login : acr_login_token =$(shell az acr login --name $(org_acr) --expose-token --query accessToken --output tsv)
proj-acr-login :
	- docker login $(org_acr_login_server) -u 00000000-0000-0000-0000-000000000000 -p "$(acr_login_token)"

proj-register-provider :
	@echo Registering OperationsManagement, OperationalInsights and Cdn
	- az provider register --namespace Microsoft.OperationsManagement
	- az provider register --namespace Microsoft.OperationalInsights
	- az provider register --namespace Microsoft.Cdn
	@echo

proj-install-cli :
	- az aks install-cli

proj-get-credentials : proj-install-cli
	- az aks get-credentials\
	  --resource-group $(proj_resource_group)\
	  --name $(proj_cluster)\
	  --admin\
      --overwrite-existing

proj-export-config : proj-get-credentials
	- cp /root/.kube/config .aks_kube_config

proj-acr-build :
	az acr build \
	--registry $(org_acr) \
	--image $(container_name) \
	--image $(container_latest) \
	--file Dockerfile \
	.

proj-create-role-assignments :     aks_id=$(shell az aks show --resource-group $(proj_resource_group) --name $(proj_cluster) --query id --output tsv)
proj-create-role-assignments : kubelet_id=$(shell az aks show --resource-group $(proj_resource_group) --name $(proj_cluster) --query identityProfile.kubeletidentity.clientId --output tsv)
proj-create-role-assignments :     acr_id=$(shell az acr show --resource-group $(org_resource_group)  --name $(org_acr)      --query id --output tsv)
proj-create-role-assignments :
	- az role assignment create\
		--assignee-object-id $(spn_oid)\
		--assignee-principal-type ServicePrincipal\
		--role "Azure Kubernetes Service RBAC Cluster Admin" --scope $(aks_id)

	- az role assignment create\
		--assignee-object-id $(spn_oid)\
		--assignee-principal-type ServicePrincipal\
		--role "Azure Kubernetes Service Cluster User Role" --scope $(aks_id)

	- az role assignment create\
		--assignee-object-id $(spn_oid)\
		--assignee-principal-type ServicePrincipal\
		--role "Azure Kubernetes Service RBAC Writer" --scope $(aks_id)

	- az role assignment create\
		--assignee-object-id $(spn_oid)\
		--assignee-principal-type ServicePrincipal\
		--role "Contributor" --scope $(acr_id)

	- az role assignment create\
		--assignee $(kubelet_id)\
		--role AcrPull --scope $(acr_id)