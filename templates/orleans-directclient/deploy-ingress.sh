#!/bin/sh

set -x

PROJECT_NAME="$1"
GIT_HASH=$(git log -1 --pretty=format:"%h")

NEW_SERVICE_NAME="${PROJECT_NAME}-${GIT_HASH}-service"
NEW_PATH="/${PROJECT_NAME}/${GIT_HASH}/*"

# Fetches an example path object and sets the new service name and path.
NEW_PATH_JSON=$(kubectl get ingress $PROJECT_NAME -o=json | jq '.spec.rules[0].http.paths[0]' | jq ".backend.service.name = \"$NEW_SERVICE_NAME\" | .path = \"$NEW_PATH\"")

echo $NEW_PATH_JSON

if [ $? -ne 0  ] || [ -z "$NEW_PATH_JSON" ]; then
    echo "No Ingress found, deploying new Ingress"
    kubectl apply -f k8s-ingress.yml
    exit 0
fi

echo "Existing Ingress found, updating paths and re-deploying."

# Deletes any existing path with the name $NEW_PATH and then appends the $NEW_PATH_JSON object to the path array.
NEW_INGRESS_SPEC=$(kubectl get ingress $PROJECT_NAME -o=json | jq "del(.spec.rules[].http.paths[] | select(.path == \"${NEW_PATH}\"))" | jq ".spec.rules[0].http.paths += [$NEW_PATH_JSON]")

echo "Updated Ingress spec:"
echo $NEW_INGRESS_SPEC | jq '.'

# Apply the ingress changes with the new path
cat <<EOF | kubectl apply -f -
$NEW_INGRESS_SPEC
EOF

