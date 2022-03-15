gh-create-repo:
	- GH_TOKEN=$(github_token) gh repo create $(github_user)/$(github_repo) --private --source . --push

gh-connect-repo:
	- GH_TOKEN=$(github_token) git remote add origin https://x-access-token:$(github_token)@github.com/$(github_user)/$(github_repo).git

az-setup-role-assignments :
	- az role assignment create --assignee $(id) --scope $(acr_id) --role "Contributor"
	- az role assignment create --assignee $(id) --scope $(aks_id) --role "Azure Kubernetes Service Cluster User Role"
	- az role assignment create --assignee $(id) --scope $(aks_id) --role "Azure Kubernetes Service RBAC Writer"
	@echo Completed setting up Role Assignments

gh-persist-secrets:
	- GH_TOKEN=$(github_token) gh secret set service_principal_id       --body $(id)
	- GH_TOKEN=$(github_token) gh secret set service_principal_password --body $(password)
	- GH_TOKEN=$(github_token) gh secret set service_principal_tenant   --body $(tenant)
	@echo Completed saving secrets to Github repo

az-create-sp: password =$(shell az ad sp create-for-rbac --name $(proj_acr_sp) --role contributor --scopes /subscriptions/$(sub) --query password --out tsv)
az-create-sp:
	$(MAKE) password=$(password) az-get-sp-props

az-get-sp-props: sleep-30
	$(MAKE) \
		password=$(password) \
		id=$(shell az ad sp list --display-name $(proj_acr_sp) --query "[0].appId" --out tsv) \
		tenant=$(shell az ad sp list --display-name $(proj_acr_sp) --query "[0].appOwnerTenantId" --out tsv) \
		acr_id=$(shell az acr show --name $(org_acr) --resource-group $(org_resource_group) --query "id" --output tsv) \
		aks_id=$(shell az aks show --name $(proj_cluster) --resource-group $(proj_resource_group) --query "id" --output tsv) \
		az-setup-role-assignments gh-persist-secrets

gh-wireup-azure: az-create-sp
	@echo Wired Up Azure and Github

gh-setup : gh-login gh-create-repo gh-wireup-azure
	@echo Created and Configured Github Repo

gh-login : secret-file=github-token.txt
gh-login :
	- rm $(secret-file)
	- echo $(GH_TOKEN) > $(secret-file)
	gh auth login --with-token < $(secret-file)
	gh auth setup-git
	- rm $(secret-file)
