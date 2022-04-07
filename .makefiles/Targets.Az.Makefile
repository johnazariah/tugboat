# Az CLI - when you have not installed AZ CLI locally, and do not want to, you can run it from inside a docker container

az-start:
	MSYS_NO_PATHCONV=1 docker run --rm --volume $(shell pwd):/code --workdir /code --interactive --tty mcr.microsoft.com/azure-cli

# These commands are to be accessed from within the docker image started above
az-login:
	az login --tenant $(tenant)
	@echo Ensure you set your default tenant and subscription in '.config/subscription.cfg'

az-sub-set: az-login
	az account set --subscription $(sub)

az-sub-show:
	az account show

az-show-regions:
	az account list-locations --query "sort_by([].{Location:name}, &Location)" -o table

az-persist-secrets-in-github : spn_tenant=$(shell az ad sp show --id $(app_id) --query appOwnerTenantId --out tsv)
az-persist-secrets-in-github :
	- gh secret set AZURE_CLIENT_ID       --body $(app_id)
	- gh secret set AZURE_TENANT_ID       --body $(spn_tenant)
	- gh secret set AZURE_SUBSCRIPTION_ID --body $(sub)

az-create-role-assignment : spn_oid=$(shell az ad sp show --id $(app_id) --query objectId --out tsv)
az-create-role-assignment :
	- az role assignment create\
		--role "Contributor"\
		--subscription $(sub)\
		--assignee-object-id $(spn_oid)\
		--assignee-principal-type ServicePrincipal

	$(MAKE)\
		app_id=$(app_id)\
		app_oid=$(app_oid)\
		spn_oid=$(spn_oid)\
		az-persist-secrets-in-github


az-create-sp : app_id=$(shell az ad app list --display-name $(proj_aad_app_name) --query [].appId    --out tsv)
az-create-sp : app_oid=$(shell az ad app list --display-name $(proj_aad_app_name) --query [].objectId --out tsv)
az-create-sp :
	- az ad sp create --id $(app_oid)
	$(MAKE)\
		app_id=$(app_id)\
		app_oid=$(app_oid)\
		az-create-role-assignment

az-create-aad-app :
	- az ad app create --display-name $(proj_aad_app_name)
	$(MAKE) az-create-sp
	$(MAKE) az-create-federated-credential

az-create-federated-credential : app_id =$(shell az ad app list --display-name $(proj_aad_app_name) --query [].appId    --out tsv)
az-create-federated-credential : app_oid=$(shell az ad app list --display-name $(proj_aad_app_name) --query [].objectId --out tsv)
az-create-federated-credential : uri="https://graph.microsoft.com/beta/applications/$(app_oid)/federatedIdentityCredentials"
az-create-federated-credential : kvp_name=\"name\":\"$(proj_aad_app_name)\"
az-create-federated-credential : kvp_issuer=\"issuer\":\"https://token.actions.githubusercontent.com\"
az-create-federated-credential : kvp_subject=\"subject\":\"repo:$(github_user)/$(github_repo):ref:refs/heads/main\"
az-create-federated-credential : kvp_description=\"description\":\"Tugboat Integration\"
az-create-federated-credential : kvp_audiences=\"audiences\":[\"api://AzureADTokenExchange\"]
az-create-federated-credential : body="{$(kvp_name),$(kvp_issuer),$(kvp_subject),$(kvp_description),$(kvp_audiences)}"
az-create-federated-credential : kvp_contenttype=\"Content-Type\":\"application/json\"
az-create-federated-credential : headers="{$(kvp_contenttype)}"
az-create-federated-credential :
	- az rest --method POST --uri $(uri) --headers $(headers) --body $(body)
