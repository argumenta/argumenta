#!/bin/bash

# argumenta-migrate.sh
# Apply migrations to the Argumenta database.

# This script's real path.
SCRIPT_FILE=$(readlink -f "$0")

# This script's source directory.
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)

# Add node binaries to path.
PATH="${SOURCE_DIR}/node_modules/.bin:${PATH}"

# The application mode.
NODE_ENV=${NODE_ENV:-'development'}

# Prefer local migration dir, if present.
if [[ -d './db/migrations' ]]; then
  MIGRATIONS_DIR="./db/migrations"
else
  MIGRATIONS_DIR="${SOURCE_DIR}/db/migrations"
fi

# Prefer system config dir, if present.
if [[ -d '/etc/argumenta' ]]; then
  CONFIG_DIR='/etc/argumenta'
else
  CONFIG_DIR='./config'
fi

# The database URL for Argumenta.
export DATABASE_URL=$(
  cd "$SOURCE_DIR"
  export NODE_ENV CONFIG_DIR
  node -e "
    var coffee = require('coffee-script');
    var url = require('./config').postgresUrl;
    console.log(url);
  "
)

#
# Gets command line options.
#
getOpts() {
  while [[ "$1" == -* ]]; do
    case "$1" in
      -d | --debug  ) DEBUG=1; shift ;;
      *             ) break ;;
    esac
  done

  if [[ $DEBUG -eq 1 ]]; then
    echo "Debug mode enabled."
    set -x
  fi

  MIGRATE_ARGS=("$@")
}

#
# Main script wraps db-migrate.
#
main() {
  getOpts "$@"
  db-migrate "${MIGRATE_ARGS[@]}" -m "$MIGRATIONS_DIR"
}

# Let's do this!
main "$@"
