# These commands are to be used to do a one-time set up of the organization-wide resources
org-cleanup:
	- az group delete --name $(org_resource_group) --yes
	@echo Completed cleaning up Tugboat-on-AKS core resources

org-setup:	org-setup-defaults \
			org-setup-rg \
			org-setup-acr \
			org-setup-afd org-setup-afd-endpoint \
			org-setup-kv \
			org-setup-lawks
	@echo Completed setting up Tugboat-on-AKS core resources

org-setup-defaults :
	@echo Setting default subscription, location and acr
	- az account set --subscription $(sub)
	- az configure --defaults location=$(org_region) acr=$(org_acr)
	@echo

org-setup-rg : org-setup-defaults
	@echo Starting to set up org resource group [$(org_resource_group)]
	- az group create\
		--name $(org_resource_group)\
		--location $(org_region)\
		--tags tugboat-org=$(org_name)
	@echo

org-setup-acr : org-setup-rg
	@echo Starting to set up org ACR [$(org_acr)]
	- az acr create\
		--name $(org_acr)\
		--resource-group $(org_resource_group)\
		--sku Basic
	@echo

org-setup-afd: org-setup-rg
	@echo Starting to set up org azure front door [$(org_azurefrontdoor)]
	- az afd profile create\
		--profile-name $(org_azurefrontdoor)\
		--resource-group $(org_resource_group)\
		--sku Standard_AzureFrontDoor

org-setup-afd-endpoint: org-setup-rg org-setup-afd
	@echo Starting to create azure front door endpoint
	- az afd endpoint create\
		--profile-name $(org_azurefrontdoor)\
		--resource-group $(org_resource_group)\
		--enabled-state Enabled\
		--endpoint-name $(org_azurefrontdoor)\
		--origin-response-timeout-seconds 60
	@echo

org-setup-kv : org-setup-rg
	@echo Starting to set up org key vault [$(org_keyvault)]
	- az keyvault create\
		--name $(org_keyvault)\
		--resource-group $(org_resource_group)\
		--location $(org_region)\
		--enabled-for-template-deployment
	@echo

org-purge-kv:
	@echo Starting to purge org key vault [$(org_keyvault)]
	- az keyvault purge\
		--subscription $(sub)\
		--name $(org_keyvault)
	@echo

org-setup-lawks : org-setup-rg
	@echo Starting to setup org LA workspace [$(org_lawks)]
	- az monitor log-analytics workspace create\
		--workspace-name $(org_lawks)\
		--resource-group $(org_resource_group)
	@echo
