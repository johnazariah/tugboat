# AKS commands

aks-switch-context :
	cp --force $$HOME/.kube/config $$HOME/.kube/config.backup
	KUBECONFIG=$$HOME/.kube/config:.aks_kube_config kubectl config view --merge --flatten > ~/.kube/merged_kubeconfig && mv ~/.kube/merged_kubeconfig ~/.kube/config
	kubectl config use-context $(proj_cluster)

aks-acr-login : acr_login_token =$(shell az acr login --name $(org_acr) --expose-token --query accessToken --output tsv)
aks-acr-login :
	- docker login $(org_acr_login_server) -u 00000000-0000-0000-0000-000000000000 -p "$(acr_login_token)"

aks-set-secrets : k8s-create-namespace aks-set-storage-secret
	@echo Completed setting up secrets

aks-set-storage-secret : proj_storage_connection_string=$(shell az storage account show-connection-string --name $(proj_storage) --resource-group $(proj_resource_group) --query connectionString --output tsv)
aks-set-storage-secret :
	@echo Starting to set up storage connection string as a secrets
	kubectl create secret generic $(proj_storage_secret)\
		--namespace $(k8s_namespace)\
		--from-literal=connection-string=$(proj_storage_connection_string)

aks-prepare : aks-acr-login aks-switch-context aks-set-secrets
	@echo Prepared context to run against remote AKS!

aks-get-credentials :
	az aks get-credentials \
	--resource-group $(proj_resource_group) \
	--name $(proj_cluster) \
	--overwrite-existing
