hello :
	@echo Welcome to the GeneratedProjectName Project
	@echo
	@echo Please update your configuration details in the '.config' directory
	@echo
	@echo If this is your very first time building a Tugboat project, run
	@echo 	make bootstrap-org -e sub=the-azure-subscription-you-want-to-use
	@echo
	@echo If you have previously set up an organization and want to add this project to it, run
	@echo 	make bootstrap-project
	@echo Or, if you want to override the project name
	@echo 	make bootstrap-project -e project=the-project-name-you-want-to-use

bootstrap-org : sub ?=Please specify Azure subscription id to use
bootstrap-org : list-config org-setup
	@echo Organization bootstrapped
	@echo
	@echo Run the following command to bootstrap your project
	@echo 	make bootstrap-project

bootstrap-project : sub ?=Please specify Azure subscription id to use
bootstrap-project : list-config init az-login az-sub-set aks-acr-login proj-setup proj-prepare-aks docker-build docker-push k8s-deploy k8s-status
	@echo Project $(project) bootstrapped
	@echo
	@echo To build and deploy your project as part of the development workflow, run
	@echo 	make build

build: list-config docker-build docker-push k8s-upgrade k8s-status
	@echo Changes pushed to the cluster!