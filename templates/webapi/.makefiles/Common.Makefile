# 
# Resources shall be named according to convention:
# https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
#

#organization configuration
org-lc:=$(shell echo $(org) | tr A-Z a-z)
org_name:=$(org-lc)-oaks-$(org_region)
org_resource_group:=rg-$(org_name)
org_acr:=$(shell echo """acr$(org-lc)$(oaks)""" | cut -c1-45 | tr A-Z a-z)
org_acr_login_server:=$(org_acr).azurecr.io
org_azurefrontdoor:=afd-$(org_name)
org_keyvault:=kv-$(org-lc)
org_lawks:=lawks-$(org_name)

# project configuration
project-lc:=$(shell echo $(project) | tr A-Z a-z)

proj_name:=$(org-lc)-$(project-lc)-$(proj_region)
proj_resource_group:=rg-$(proj_name)
proj_cluster:=aks-$(project-lc)
proj_appgateway:=agw-$(project-lc)
proj_acr_sp:=sp-$(proj_name)
proj_agic_nsg_name:=nsg-agic-$(project-lc)

#github configuration
github_repo           ?=$(org-lc)-$(project-lc)

# container name
org_acr_login_server  ?=local
git_branch            ?=$(subst /,--,$(shell git rev-parse --abbrev-ref HEAD))
git_latest_hash       ?=$(shell git log -1 --pretty=format:"%h")
image_tag             ?=$(git_latest_hash)
container_name        ?=$(org_acr_login_server)/$(project-lc):$(image_tag)

# k8s namespace
k8s_namespace         ?=green

# Initialize
init : git-init
	git status

git-init :
	@echo registering $(git_username) [$(git_email)]
	git init
	git config user.email $(git_email)
	git config user.name  $(git_username)
	git add .
	git commit -m "Initial commit of $(project-lc)"
	git branch -m main

# Utilities
get-random-number:
	@echo $$RANDOM

list-config:
	@echo
	@echo Modify these values by editing files in the '.config' directory.
	@echo
	@echo "git_username                   : "[$(git_username)]
	@echo "git_email                      : "[$(git_email)]
	@echo
	@echo "github_user                    : "[$(github_user)]
	@echo "github_repo                    : "[$(github_repo)]
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
	@echo "project                        : "[$(project)]
	@echo "proj_resource_group            : "[$(proj_resource_group)]
	@echo "proj_region                    : "[$(proj_region)]
	@echo "proj_cluster                   : "[$(proj_cluster)]
	@echo
