# Local/Remote Kubernetes Commands
# For Local Use, just run these targets
# For Remote Use, ensure that you have deployed the Organization and Project resources, switch context, and then run these targets

k8s-cleanup :
	- kubectl delete namespace $(k8s_namespace)

k8s-deploy : k8s-create-namespace k8s-set-default-namespace k8s-upgrade
	@echo Clean-deployed to $(k8s_namespace)

k8s-upgrade : k8s-replace-image-tag k8s-apply
	@echo Upgraded $(k8s_namespace)

k8s-apply : k8s-replace-image-tag
	kubectl apply -f k8s-deployment.yml
	/bin/sh .scripts/deploy-ingress.sh $(project-lc)

k8s-status :
	- kubectl get namespace
	- kubectl get all
	- kubectl get ingress

k8s-dashboard : k8s-deploy-dashboard k8s-setup-rbac
	kubectl proxy

k8s-create-namespace :
	- kubectl create namespace $(k8s_namespace)

k8s-set-default-namespace:
	- kubectl config set-context --current --namespace $(k8s_namespace)

k8s-replace-image-tag :
	sed -e \
		"s|{org-name}|$(org-lc)|g;\
		 s|{project-name}|$(project-lc)|g;\
		 s|{image-tag}|$(image_tag)|g;\
		 s|{image-name}|$(container_name)|g;\
		 s|{storage-secret-name}|$(proj_storage_secret)|g;"\
		.scripts/k8s-deployment.ymlt > k8s-deployment.yml
	sed -e \
		"s|{image-name}|$(container_name)|g;\
		 s|{project-name}|$(project-lc)|g;\
		 s|{image-tag}|$(image_tag)|g;\
		 s|{org-name}|$(org-lc)|g;"\
		.scripts/k8s-ingress.ymlt > k8s-ingress.yml

k8s-deploy-dashboard :
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

k8s-setup-rbac :
	kubectl apply -f .scripts/local-k8s-rbac.yml
	kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
