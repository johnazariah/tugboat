hello :
	@echo Welcome to the GeneratedProjectName Project
	@echo
	@echo Please modify any defaults in the 'Defaults.Makefile' file. These changes _will_ get picked up by the CI/CD pipeline.
	@echo
	@echo First set-up your local environment and the github repo by running :
	@echo 	make tugboat-init
	@echo

tugboat-init : git-init az-login az-sub-set gh-login gh-create-repo
	- proj_aad_app_name=$(proj_aad_app_name)\
	  sub=$(sub)\
	  github_user=$(github_user)\
	  github_repo=$(github_repo)\
	  .scripts/create-aad-app.sh

tugboat-setup-org-bicep:
	az deployment sub create --name "dply-$(org)-tgbt" --location $(org_region) --parameters org=$(org) --template-file .azure/org/org_setup.bicep

tugboat-setup-proj-bicep:
	az deployment sub create --name "dply-$(org)-$(project)" --location $(proj_region) --parameters org=$(org) project=$(project) --template-file .azure/proj/proj_setup.bicep

tugboat-setup-proj-cluster : proj-setup-aks proj-setup-frontdoor proj-setup-awg-nsgs

tugboat-setup-role-assignments: proj-create-role-assignments

tugboat-delete-all-resources:
	- az group list --tag tugboat-org --query [].name --output tsv | xargs -otl az group delete --no-wait --yes -n
	- $(MAKE) org-purge-kv

bootstrap-env : az-sub-set gh-login proj-prepare-aks status
	@echo Environment bootstrapped
	@echo
	@echo Make changes to your code, commit and push to your main branch on Github and
	@echo 	they will automatically be built and deployed!

manual-firstbuild: list-config docker-build docker-push k8s-deploy k8s-status
	@echo Project deployed to the cluster!
	@echo
	@echo To build and deploy your project as part of your local-development workflow, run
	@echo 	make build
	$(MAKE) url

manual-build: list-config docker-build docker-push k8s-upgrade k8s-status
	@echo Changes pushed to the cluster!
	$(MAKE) url

url : hostname=$(shell az afd endpoint show --resource-group $(org_resource_group) --endpoint-name $(org_azurefrontdoor) --profile-name $(org_azurefrontdoor) --query hostName --output tsv)
url : url=https://$(hostname)/$(project)/$(image_tag)/index.html
url :
	@echo
	@echo The landing page for the latest commit \[$(image_tag)\] is found at: $(url)
	@echo

status: k8s-status url