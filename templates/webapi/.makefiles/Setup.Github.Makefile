#github-login :
#	- GH_TOKEN=$(github_token) gh auth login --hostname github.com #--git-protocol https

gh-create-repo:
	- GH_TOKEN=$(github_token) gh repo create $(github_user)/$(github_repo) --private --source . --push

gh-connect-repo:
	- git remote add origin https://x-access-token:$(github_token)@github.com/$(github_user)/$(github_repo).git

gh-set-secrets: password =$(shell az ad sp create-for-rbac --name $(proj_acr_sp) --role contributor --scopes /subscriptions/$(sub) --query password --out tsv)
gh-set-secrets: id       =$(shell az ad sp list --display-name $(proj_acr_sp) --query "[0].appId" --out tsv)
gh-set-secrets: tenant   =$(shell az ad sp list --display-name $(proj_acr_sp) --query "[0].appOwnerTenantId" --out tsv)
gh-set-secrets: acr_id   =$(shell az acr show --name $(org_acr) --resource-group $(org_resource_group) --query "id" --output tsv)
gh-set-secrets:
	- az role assignment create --assignee $(id) --scope $(acr_id) --role "Contributor"
	- GH_TOKEN=$(github_token) gh secret set GIT_ACCESS_TOKEN           --body $(github_token)
	- GH_TOKEN=$(github_token) gh secret set service_principal_password --body $(password)
	- GH_TOKEN=$(github_token) gh secret set service_principal_id       --body $(id)
	- GH_TOKEN=$(github_token) gh secret set service_principal_tenant   --body $(tenant)
	- GH_TOKEN=$(github_token) gh secret set registry                   --body $(org_acr)
	- GH_TOKEN=$(github_token) gh secret set repository                 --body $(org_acr_login_server)
	- GH_TOKEN=$(github_token) gh secret set image                      --body $(project-lc)

gh-setup : gh-create-repo gh-set-secrets
	@echo Created and Configured Github Repo