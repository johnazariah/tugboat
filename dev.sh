#/bin/sh

MSYS_NO_PATHCONV=1 docker run --rm --volume /c/code/GeneratedProjectName:/code --volume /var/run/docker.sock:/var/run/docker.sock --publish 80:80 --workdir /code --interactive --tty johnazariah/tugboat:latest