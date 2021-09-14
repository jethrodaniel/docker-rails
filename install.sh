#!/usr/bin/env bash

# $1 - msg
#
die() {
  echo "$1"
  exit 1
}

# $1 - cmd
#
ensure_cmd_exists() {
  if command -v "$1" >/dev/null; then
    echo "[ok] found \`$1\`..."
  else
    die "[err] \`$1\` not found. Exiting..."
  fi
}

echo "=== Dockerizing Rails... ==="
ensure_cmd_exists "docker"
ensure_cmd_exists "docker-compose"

git clone https://github.com/jethrodaniel/docker-rails .docker-rails \
  && cp -v .docker-rails/docker-compose.yml . \
  && cp -v .docker-rails/Dockerfile . \
  && cp -v .docker-rails/.dockerignore . \
  && cp -v .docker-rails/docker-compose.yml . \
  && cp -v .docker-rails/docker-entrypoint.sh . \
  && cp -v .docker-rails/.env . \
  && cp -v .docker-rails/.pryrc . \
  && cp -v .docker-rails/webpack.js config/webpack/development.js \
  && rm -fr .docker-rails \
  && echo -e "=== Done ==="
