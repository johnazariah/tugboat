# AKS commands

aks-switch-context :
	cp --force $$HOME/.kube/config $$HOME/.kube/config.backup
	KUBECONFIG=$$HOME/.kube/config:.aks_kube_config kubectl config view --merge --flatten > ~/.kube/merged_kubeconfig && mv ~/.kube/merged_kubeconfig ~/.kube/config
	kubectl config use-context $(proj_cluster)

aks-acr-login :
	- docker login $(org_acr_login_server) -u 00000000-0000-0000-0000-000000000000 -p $(org_acr_login_token)

aks-set-secrets : k8s-create-namespace
	@echo Completed setting up secrets

aks-prepare : aks-acr-login aks-switch-context aks-set-secrets
	@echo Prepared context to run against remote AKS!
