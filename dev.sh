#/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

FLAGS=
if [ `uname -m` == "arm64" ]; then
    FLAGS="--platform linux/amd64"
fi

MSYS_NO_PATHCONV=1 docker run $FLAGS --rm --volume $SCRIPT_DIR:/code --volume /var/run/docker.sock:/var/run/docker.sock --publish 80:80 --workdir /code --interactive --tty westisland/tugboat:latest
