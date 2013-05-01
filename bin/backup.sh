#!/bin/bash

# argumenta-backup.sh
# Creates a backup of the argumenta database.

# Today's date.
DATE=$(date +%Y.%m.%d)

# The postgres database name.
DB_NAME='argumenta'

# The backups directory.
BACKUP_DIR='/home/argumenta-backup'

# The backup file.
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql"

#
# Creates the backups directory.
#
createBackupDir() {
  if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Creating backup dir: '$BACKUP_DIR'."
    mkdir -p "$BACKUP_DIR"
    chown argumenta-backup:argumenta-backup "$BACKUP_DIR"
  fi
}

#
# Creates a backup of the current database.
#
backupDatabase() {
  echo "Creating backup: '$BACKUP_FILE'."
  sudo -u postgres \
    /usr/bin/pg_dump "$DB_NAME" > "$BACKUP_FILE"
  chown argumenta-backup:argumenta-backup "$BACKUP_FILE"
  chmod 0660 "$BACKUP_FILE"
}

#
# Main script.
#
main() {
  createBackupDir
  backupDatabase
}

# Let's do this!
main "$@"
