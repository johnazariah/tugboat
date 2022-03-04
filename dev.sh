#/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

FLAGS=
if [ `uname -m` == "arm64" ]; then
    FLAGS="--platform linux/amd64"
fi

MSYS_NO_PATHCONV=1 docker run \
    $FLAGS \
    --publish 80:80 \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume $SCRIPT_DIR:/code \
    --workdir /code \
    --rm \
    --interactive \
    --tty \
    westisland/tugboat:latest
