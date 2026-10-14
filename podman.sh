#!/bin/sh
# Run a command in a Node.js LTS container (same Node version as CI), for hosts
# without a recent Node.js. The repository is mounted at /src; files created in
# the container are owned by the calling user.
#
#   ./podman.sh npm ci
#   ./podman.sh npm run dev -- --bind 0.0.0.0   # http://localhost:1313/
#   ./podman.sh npm run build
set -eu

tty=
[ -t 0 ] && tty=-t

exec podman run --rm -i $tty \
	--userns=keep-id \
	-v "$(dirname "$(realpath "$0")")":/src:Z \
	-w /src \
	-p 127.0.0.1:1313:1313 \
	-e HOME=/tmp \
	-e HUGO_GITHUB_TOKEN \
	docker.io/library/node:lts \
	"$@"
