#!/bin/bash

# argumenta-restore.sh
# Restore the argumenta database from a backup file.

# Exit on any error.
set -e

# The database to restore.
DB_NAME='argumenta'

# The backup file to restore from.
BACKUP_FILE=''

#
# Prints usage info.
#
usage() {
  cat <<END

  ${0} [options] <db> <file>

    db                The database name to restore to.
    file              The backup file to load.

  Options:
    -d, --debug       Show additional debug info.
    -h, --help        Show this usage info.

END
}

#
# Creates the database.
#
createDatabase() {
  echo "Creating database '$DB_NAME'."
  sudo -u postgres \
    psql -c "CREATE DATABASE \"$DB_NAME\"
             WITH OWNER \"$DB_NAME\";"
}

#
# Restores the database.
#
restoreBackup() {
  if [[ -f "$BACKUP_FILE" ]]; then
    echo "Restoring database '$DB_NAME' from '$BACKUP_FILE'."
    sudo -u postgres \
      psql "$DB_NAME" < "$BACKUP_FILE"
  else
    echo "Missing backup file '$BACKUP_FILE'."
    echo "Aborting restore."
    exit 1
  fi
}

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

  DB_NAME="$1"; shift
  BACKUP_FILE="$1"; shift

  if [[ ! "$DB_NAME" == argumenta* ]]; then
    echo "Error: Database name should begin with 'argumenta'."
    exit 1
  fi
  if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "Error: Missing backup file '$BACKUP_FILE'."
    exit 1
  fi
}

#
# Main script.
#
main() {
  getOpts "$@"
  createDatabase
  restoreBackup
  echo "Done!"
}

main "$@"
