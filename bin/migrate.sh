#!/bin/bash

# argumenta-migrate.sh
# Apply migrations to the Argumenta database.

# This script's real path.
SCRIPT_FILE=$(readlink -f "$0")

# This script's source directory.
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)

# Add node binaries to path.
PATH="${SOURCE_DIR}/node_modules/.bin:${PATH}"

# The migrations directory.
MIGRATIONS_DIR="${SOURCE_DIR}/db/migrations"

# The application mode.
NODE_ENV=${NODE_ENV:-'development'}

# The database URL for Argumenta.
export DATABASE_URL=$(
  node -e "
    var coffee = require('coffee-script');
    var url = require('./config').postgresUrl;
    console.log(url);
  "
)

# Export config dir for server installs.
if [[ -d '/etc/argumenta' ]]; then
  export CONFIG_DIR='/etc/argumenta'
fi

#
# Gets command line options.
#
getOpts() {
  while [[ "$1" == -* ]]; do
    case "$1" in
      -d | --debug  ) DEBUG=1; shift ;;
      -h | --help   ) usage; exit 0 ;;
      *             ) shift ;;
    esac
  done

  if [[ $DEBUG -eq 1 ]]; then
    echo "Debug mode enabled."
    set -x
  fi
}

#
# Main script wraps db-migrate.
#
main() {
  db-migrate -m "$MIGRATIONS_DIR" "$@"
}

# Let's do this!
main "$@"
