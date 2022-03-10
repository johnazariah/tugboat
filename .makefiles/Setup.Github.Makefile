#github-login :
#	- GH_TOKEN=$(github_token) gh auth login --hostname github.com #--git-protocol https

gh-create-repo:
	- GH_TOKEN=$(github_token) gh repo create $(github_user)/$(github_repo) --private --source . --push

gh-connect-repo:
	- GH_TOKEN=$(github_token) git remote add origin https://x-access-token:$(github_token)@github.com/$(github_user)/$(github_repo).git

gh-wireup-azure: password =$(shell az ad sp create-for-rbac --name $(proj_acr_sp) --role contributor --scopes /subscriptions/$(sub) --query password --out tsv)
gh-wireup-azure: id       =$(shell az ad sp list --display-name $(proj_acr_sp) --query "[0].appId" --out tsv)
gh-wireup-azure: tenant   =$(shell az ad sp list --display-name $(proj_acr_sp) --query "[0].appOwnerTenantId" --out tsv)
gh-wireup-azure: acr_id   =$(shell az acr show --name $(org_acr) --resource-group $(org_resource_group) --query "id" --output tsv)
gh-wireup-azure: aks_id   =$(shell az aks show --name $(proj_cluster) --resource-group $(proj_resource_group) --query "id" --output tsv)
gh-wireup-azure:
	- sleep 30
	- az role assignment create --assignee $(id) --scope $(acr_id) --role "Contributor"
	- az role assignment create --assignee $(id) --scope $(aks_id) --role "Azure Kubernetes Service Cluster User Role"
	- az role assignment create --assignee $(id) --scope $(aks_id) --role "Azure Kubernetes Service RBAC Writer"
	- GH_TOKEN=$(github_token) gh secret set service_principal_id       --body $(id)
	- GH_TOKEN=$(github_token) gh secret set service_principal_password --body $(password)
	- GH_TOKEN=$(github_token) gh secret set service_principal_tenant   --body $(tenant)

gh-setup : gh-create-repo gh-wireup-azure
	@echo Created and Configured Github Repo
