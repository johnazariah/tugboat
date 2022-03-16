# Docker commands

docker-list :
	docker images

docker-build :
	docker build . --rm --build-arg config=$(proj_config) --file Dockerfile --tag $(container_name)
	@echo Built and tagged images

docker-push :
	docker push $(container_name)
	@echo Pushed images to container registry

docker-run :
	docker run \
		--rm \
		--publish 30000:30000 \
		--publish 11111:11111 \
		--publish 5000:80 \
		--publish 8080:8080 \
		$(container_name)
	@echo Launched container

docker-image-explore :
	@echo Showing the insides of the latest container
	docker run -it --entrypoint sh $(container_name)

docker-show:
	$(eval container_ident   := $(shell docker ps | awk '$$2 ~ "$(container_name)" {print $$1}'))
	$(eval container_address := $(shell docker container inspect $(container_ident) --format "{{.NetworkSettings.IPAddress}}"))
	@echo Running the docker image at $(container_ident) @ $(container_address)

docker-stop :
	@echo Stopping all  containers
	- docker stop $(shell docker ps -aq)

docker-kill : docker-stop
	@echo Killing and removing all containers
	- docker rm -f $(shell docker ps -aq)
	- docker kill  $(shell docker ps -aq)

docker-clean : docker-kill
	@echo Pruning all images
	- docker image prune -af

