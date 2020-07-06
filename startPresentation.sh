#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -o monitor # Job Control, needed for "fg"

echo "Starting presentation on localhost:8000" 

CONTAINER=$(docker run --rm --detach \
    -v $(pwd)/css/cloudogu-black.css:/reveal/css/cloudogu-black.css \
    -v $(pwd)/docs/slides:/reveal/docs/slides \
    -v $(pwd)/images:/reveal/images \
    -v $(pwd)/resources:/resources \
    -e TITLE="$(grep -r 'TITLE' Dockerfile | sed "s/.*TITLE='\(.*\)'.*/\1/")" \
    -e THEME_CSS='css/cloudogu-black.css' \
    -p 8000:8000 -p 35729:35729 \
    cloudogu/reveal.js:$(head -n1 Dockerfile | sed 's/.*:\([^ ]*\) .*/\1/')-dev)

# Print logs in background while waiting for container to come up
docker attach ${CONTAINER} &

until $(curl -s -o /dev/null --head --fail localhost:8000); do sleep 1; done

# Open Browser
xdg-open http://localhost:8000

# Bring container to foreground, so it can be stopped using ctrl+c. 
# But don't output "docker attach ${CONTAINER}"
fg > /dev/null
