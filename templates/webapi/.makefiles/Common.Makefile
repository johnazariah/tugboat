# container name
org_acr_login_server  ?=local
git_branch            ?=$(subst /,--,$(shell git rev-parse --abbrev-ref HEAD))
git_latest_hash       ?=$(shell git log -1 --pretty=format:"%h")
image_tag             ?=$(git_branch).$(git_latest_hash)
container_name        ?=$(org_acr_login_server)/$(project-lc):$(image_tag)

# k8s namespace
k8s_namespace         ?=green

# Initialize
init : git-init
	git status

git-init :
	git init
	git branch -m main
	git add .
	git commit -m "Initial commit of GeneratedProjectName"

# Utilities
get-random-number:
	@echo $$RANDOM

list-config:
	@echo
	@echo Modify these values by editing files in the '.config' directory.
	@echo
	@echo "sub                            : "[$(sub)]
	@echo "org                            : "[$(org)]
	@echo "container_name                 : "[$(container_name)]
	@echo
	@echo "org_name                       : "[$(org_name)]
	@echo "org_region                     : "[$(org_region)]
	@echo "org_resource_group             : "[$(org_resource_group)]
	@echo "org_acr                        : "[$(org_acr)]
	@echo "org_acr_login_server           : "[$(org_acr_login_server)]
	@echo "org_azurefrontdoor             : "[$(org_azurefrontdoor)]
	@echo "org_keyvault                   : "[$(org_keyvault)]
	@echo "org_lawks                      : "[$(org_lawks)]
	@echo
	@echo "proj_resource_group            : "[$(proj_resource_group)]
	@echo "proj_region                    : "[$(proj_region)]
	@echo "proj_cluster                   : "[$(proj_cluster)]
	@echo