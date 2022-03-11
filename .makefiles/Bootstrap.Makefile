hello :
	@echo Welcome to the GeneratedProjectName Project
	@echo
	@echo Please update your configuration details in the '.config' directory
	@echo
	@echo First login and set the default subscription by running:
	@echo 	make bootstrap-init [-e sub=the-azure-subscription-you-want-to-use]
	@echo

bootstrap-init : sub ?=Please specify Azure subscription id to use
bootstrap-init: init az-login az-sub-set
	@echo Logged in
	@echo
	@echo If this is your very first time building a Tugboat project, run
	@echo 	make bootstrap-org [-e org=the-organization-name-you-want-to-use]
	@echo
	@echo If you have previously set up an organization and want to add this project to it, run
	@echo 	make bootstrap-project [-e project=the-project-name-you-want-to-use]
	@echo

bootstrap-org : list-config org-setup org-login-acr
	@echo Organization bootstrapped
	@echo
	@echo Run the following command to bootstrap your project
	@echo 	make bootstrap-project

bootstrap-project : list-config aks-acr-login proj-setup proj-prepare-aks
	@echo Project $(project) bootstrapped and deployed!
	@echo
	@echo Run the following command to bootstrap your project
	@echo 	make bootstrap-github

bootstrap-github : sleep-60 list-config gh-setup
	@echo Github repository setup!
	@echo
	@echo Make changes to your code, commit and push to your main branch on Github and
	@echo 	they will automatically be built and deployed!
	@echo

manual-firstbuild: list-config docker-build docker-push k8s-deploy k8s-status
	@echo Project deployed to the cluster!
	@echo
	@echo To build and deploy your project as part of your local-development workflow, run
	@echo 	make build

manual-build: list-config docker-build docker-push k8s-upgrade k8s-status
	@echo Changes pushed to the cluster!