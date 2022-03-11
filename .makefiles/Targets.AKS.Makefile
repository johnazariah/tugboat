# AKS commands

aks-switch-context :
	cp --force $$HOME/.kube/config $$HOME/.kube/config.backup
	KUBECONFIG=$$HOME/.kube/config:.aks_kube_config kubectl config view --merge --flatten > ~/.kube/merged_kubeconfig && mv ~/.kube/merged_kubeconfig ~/.kube/config
	kubectl config use-context $(proj_cluster)

aks-acr-login : acr_login_token =$(shell az acr login --name $(org_acr) --expose-token --query accessToken -o tsv)
aks-acr-login :
	- docker login $(org_acr_login_server) -u 00000000-0000-0000-0000-000000000000 -p "$(acr_login_token)"

aks-set-secrets : k8s-create-namespace
	@echo Completed setting up secrets

aks-prepare : aks-acr-login aks-switch-context aks-set-secrets
	@echo Prepared context to run against remote AKS!

aks-get-credentials :
	az aks get-credentials \
	--resource-group $(proj_resource_group) \
	--name $(proj_cluster) \
	--overwrite-existing

acr-build :
	az acr build \
	--registry $(org_acr) \
	--image $(container_name) \
	--file Dockerfile \
	.

	az acr build \
	--registry $(org_acr) \
	--image $(container_latest) \
	--file Dockerfile \
	.