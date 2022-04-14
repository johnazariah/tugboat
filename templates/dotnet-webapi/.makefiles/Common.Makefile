#
# Resources shall be named according to convention:
# https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
#

# MAKEFLAGS += -j8

#organization configuration
# These should be in sync with the naming patterns in the bicep files
org-lc:=$(shell echo $(org) | tr A-Z a-z)
org_name:=$(org-lc)-tgbt-$(org_region)
org_resource_group:=rg-$(org_name)
org_acr_name=acr${org-lc}
org_acr:=$(shell echo """$(org_acr_name)""" | cut -c1-45 | tr A-Z a-z)
org_acr_login_server:=$(org_acr).azurecr.io
org_azurefrontdoor:=afd-$(org-lc)
org_keyvault:=kv-$(org-lc)
org_lawks:=lawks-$(org-lc)

# project configuration
# These should be in sync with the naming patterns in the bicep files
project-lc:=$(shell echo $(project) | tr A-Z a-z)

proj_name:=$(org-lc)-$(project-lc)-$(proj_region)
proj_resource_group:=rg-$(proj_name)
proj_cluster:=aks-$(project-lc)
proj_appgateway:=agw-$(project-lc)
proj_agic_nsg_name:=nsg-agic-$(project-lc)
proj_storage=$(shell echo """stg$(org-lc)$(project-lc)""" | cut -c1-45 | tr A-Z a-z)
proj_storage_secret=secret-$(proj_storage)

proj_aad_app_name=tgbt-$(org-lc)-$(project-lc)

#github configuration
github_repo           ?=$(org-lc)-$(project-lc)

# container name
org_acr_login_server  ?=local
git_branch            ?=$(subst /,--,$(shell git rev-parse --abbrev-ref HEAD))
git_latest_hash       ?=$(shell git log -1 --pretty=format:"%h")
image_tag             ?=$(git_latest_hash)
container_name        ?=$(org_acr_login_server)/$(project-lc):$(image_tag)
container_latest      ?=$(org_acr_login_server)/$(project-lc):latest

# k8s namespace
k8s_namespace         ?=green

# Initialize
init : git-init
	git status

init-fixup-readme:
	$(MAKE) replace_pattern=_GITHUB_USER_ replacement_pattern=$(github_user) replace_in_file=README.md replace-pattern
	$(MAKE) replace_pattern=_ORG_         replacement_pattern=$(org-lc)      replace_in_file=README.md replace-pattern
	$(MAKE) replace_pattern=_PROJECT_     replacement_pattern=$(project-lc)  replace_in_file=README.md replace-pattern

git-init :
	@echo registering $(git_username) [$(git_email)]
	- git init
	- git config user.email                                   $(git_email)
	- git config user.name                                    "$(git_username)"
	- git config diff.astextplain.textconv                     astextplain
	- git config filter.lfs.clean                             "git-lfs clean -- %f"
	- git config filter.lfs.smudge                            "git-lfs smudge -- %f"
	- git config filter.lfs.process                           "git-lfs filter-process"
	- git config filter.lfs.required                           true
	- git config core.autocrlf                                 true
	- git config core.fscache                                  true
	- git config core.symlinks                                 true
	- git config core.editor                                   vim
	- git config core.autocrlf                                 true
	- git config core.repositoryformatversion                  0
	- git config core.filemode                                 true
	- git config core.bare                                     false
	- git config core.logallrefupdates                         true
	- git config core.ignorecase                               true
	- git config pull.rebase                                   true
	- git config init.defaultbranch                            main
	- git config alias.lga                                    "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
	- git config alias.lg                                     "lga -20"
	- git config alias.ca                                     "commit -a"
	- git config alias.ci                                     "commit"
	- git config alias.st                                     "status"
	- git config alias.co                                     "checkout"
	- git config alias.br                                     "branch"
	- git config alias.fop                                    "fetch origin --prune"
	- git config alias.cob                                    "checkout -b"
	- git config alias.rom                                    "rebase origin/main"
	- git config alias.new                                    "!git init && git symbolic-ref HEAD refs/heads/main"
	- git config alias.alias                                  "!git config --get-regexp ^alias\. | sed -e s/^alias\.// -e s/\ /\ =\ /"
	- git config branch.main.remote                           "origin"
	- git config branch.main.merge                            "refs/heads/main"
	- git config credential.https://dev.azure.com.usehttppath  true
	- git add .
	- git commit -m "Initial commit of $(project-lc)"
	- git branch -m main

# Utilities
get-random-number:
	@echo $$RANDOM

list-config:
	@echo
	@echo Modify these values by editing files in Defaults.Makefile.
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
	@echo "proj_acr_sp                    : "[$(proj_acr_sp)]
	@echo "proj_storage                   : "[$(proj_storage)]
	@echo "proj_storage_connection_string : "[$(proj_storage_connection_string)]
	@echo "proj_storage_secret            : "[$(proj_storage_secret)]
	@echo

sleep-% :
	- sleep $*

replace-pattern :
ifneq ("$(wildcard $(replace_in_file))", "")
	sed -e "s/$(replace_pattern)/$(replacement_pattern)/g" $(replace_in_file) > $(replace_in_file).tmp
	mv $(replace_in_file).tmp $(replace_in_file)
endif
