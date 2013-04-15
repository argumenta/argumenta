#!/bin/bash

# setup-postgres.sh
# Sets up Postgres by creating a user, db, and initializing the schema.

# This script's real path.
SCRIPT_FILE=$(readlink -f "$0")

# This script's source directory.
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)

# Database Name
DB=${DB:="argumenta"}

# Database User
DB_USER=${DB_USER:="argumenta"}

# Database User's Password
DB_USER_PASSWORD=${DB_USER_PASSWORD:=""}

# Test only mode
TEST_ONLY=0

#
# Print usage info.
#
usage() {
  cat <<-End

  Usage: setup-postgres.sh [options] [<db>]

    <db>          Name of database to create; defaults to 'argumenta'.

  Options:

    -h, --help:          Show this help info.
    -u, --user <user>:   Database user to create.
    -p, --pass <pass>:   Database user's password.
    -t, --test-only:     Do nothing; but print what would happen.

End
}

#
# Parse command line options.
#
getOpts() {
  while [[ "$1" == -* ]]; do
    case "$1" in
      -h | --help      ) usage; exit 0; shift ;;
      -u | --user      ) DB_USER="$2"; shift; shift ;;
      -p | --pass      ) DB_USER_PASSWORD="$2"; shift; shift ;;
      -t | --test-only ) TEST_ONLY=1; shift ;;
      *                ) shift ;;
    esac
  done

  test "$1" && \
    DB="$1"
}

#
# Main entry point.
#
main() {
  getOpts "$@"

  if [[ $TEST_ONLY -eq 1 ]]; then
    echo "Running test-only. Would use settings:"
    echo "DB: $DB"
    echo "DB_USER: $DB_USER"
    echo "DB_USER_PASSWORD: $DB_USER_PASSWORD"
    exit 0
  fi

  # Create Postgres User
  sudo -u postgres \
    psql -c "CREATE ROLE \"${DB_USER}\" WITH LOGIN
             ENCRYPTED PASSWORD '${DB_USER_PASSWORD}';"

  # Create Postgres Database
  sudo -u postgres \
    psql -c "CREATE DATABASE \"$DB\"
             WITH OWNER \"$DB_USER\";"

  # Set Postgres client options
  export PGOPTIONS='--client-min-messages=warning' \
         PGPASSWORD="$DB_USER_PASSWORD"

  # Init schema
  psql -U $DB_USER -h localhost \
       -f "${SOURCE_DIR}/db/schema.sql" $DB

  # Check status and exit
  psql -U $DB_USER -h localhost \
       -c "SELECT username FROM Users;" $DB

  if [[ "$?" != "0" ]];  then
    echo "Setup failed."
    exit 1
  else
    echo "Setup complete!"
  fi
}

# Let's do this!
main "$@"
