# Az CLI - when you have not installed AZ CLI locally, and do not want to, you can run it from inside a docker container

az-start:
	MSYS_NO_PATHCONV=1 docker run --rm --volume $(shell pwd):/code --workdir /code --interactive --tty mcr.microsoft.com/azure-cli

# These commands are to be accessed from within the docker image started above
az-login:
	az login --tenant $(tenant)
	@echo Ensure you set your default tenant and subscription in '.config/subscription.cfg'

az-sub-set:
	az account set --subscription $(sub)

az-sub-show:
	az account show

az-show-regions:
	az account list-locations --query "sort_by([].{Location:name}, &Location)" -o table

az-new-all : az-new-org az-new-proj
	@echo

az-new-org : org-setup
	@echo Completed setting up new organization [$(org)]]

az-new-proj :  paks-setup paks-prepare-aks org-login-acr
	@echo Completed setting up new project [$(project)] in organization [$(org)]
