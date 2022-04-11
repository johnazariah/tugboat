hello :
	@echo Welcome to the GeneratedProjectName Project
	@echo
	@echo Please modify any defaults in the 'Defaults.Makefile' file. These changes _will_ get picked up by the CI/CD pipeline.
	@echo
	@echo If this is the first time you are here, set-up your git and github repo by running :
	@echo 	make tugboat-init
	@echo
	@echo If your infrastructure has already been deployed, run the following command to prepare your environment to interact with your AKS cluster.
	@echo
	@echo   make tugboat-prepare-env
	@echo

tugboat-init : git-init az-login az-sub-set gh-login gh-create-repo
	- proj_aad_app_name=$(proj_aad_app_name)\
	  sub=$(sub)\
	  github_user=$(github_user)\
	  github_repo=$(github_repo)\
	  .scripts/create-aad-app.sh

	$(MAKE) replace_pattern=_GITHUB_USER_ replacement_pattern=$(github_user) replace_in_file=README.md replace-pattern
	
	@echo Your GitHub Repo is ready. 
	@echo Now is a good time to go to the GitHub repo and run the `Azure Infrastructure Setup` pipeline to set up your Azure Infrastructure.
	@echo When that is done, run the `Build and Deploy to AKS` pipeline to build and deploy your project to Azure Kubernetes Service.
	@echo After the pipelines have completed, run the following command to prepare your environment to interact with your AKS cluster.
	@echo
	@echo   make tugboat-connect-aks
	@echo

tugboat-setup-org-bicep:
	az deployment sub create --name "dply-$(org)-tgbt" --location $(org_region) --parameters org=$(org) --template-file .azure/org/org_setup.bicep

tugboat-setup-proj-bicep:
	az deployment sub create --name "dply-$(org)-$(project)" --location $(proj_region) --parameters org=$(org) project=$(project) --template-file .azure/proj/proj_setup.bicep

tugboat-setup-proj-cluster : proj-setup-aks proj-setup-frontdoor proj-setup-awg-nsgs

tugboat-setup-role-assignments: proj-create-role-assignments

tugboat-connect-aks : proj-prepare-aks status

tugboat-prepare-env : az-login az-sub-set gh-login tugboat-connect-aks
	@echo Environment bootstrapped
	@echo
	@echo Make changes to your code, commit and push to your main branch on Github and
	@echo 	they will automatically be built and deployed!

tugboat-delete-all-resources:
	- az group list --tag tugboat-org --query [].name --output tsv | xargs -otl az group delete --no-wait --yes -n
	- $(MAKE) org-purge-kv

url : hostname=$(shell az afd endpoint show --resource-group $(org_resource_group) --endpoint-name $(org_azurefrontdoor) --profile-name $(org_azurefrontdoor) --query hostName --output tsv)
url : url=https://$(hostname)/$(project)/$(image_tag)/index.html
url :
	@echo
	@echo The landing page for the latest commit \[$(image_tag)\] is found at: $(url)
	@echo

status: k8s-status url