#!/bin/bash

# argumenta-backup.sh
# Creates a backup of the argumenta database.

# Today's date.
DATE=$(date +%Y.%m.%d)

# The postgres database name.
DB_NAME='argumenta'

# The backups directory.
BACKUP_DIR='/home/argumenta-backup/backups'

# The backup name.
BACKUP_NAME="${DB_NAME}_${DATE}.sql"

# The backup file.
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_NAME}"

# Backup rotation directories.
DAILY_DIR="${BACKUP_DIR}/daily"
WEEKLY_DIR="${BACKUP_DIR}/weekly"
MONTHLY_DIR="${BACKUP_DIR}/monthly"

#
# Prints usage information.
#
usage() {
  cat <<-End

  Usage: $0 [options]

  Options:
    -d, --debug : Show additional debug info.
    -h, --help  : Show this usage info.

End
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
}

#
# Creates the backup directories.
#
createBackupDirs() {
  echo "Creating backup dir: '$BACKUP_DIR'."
  mkdir -p "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR/"{daily,monthly,weekly}
  chown -R argumenta-backup:argumenta-backup "$BACKUP_DIR"
}

#
# Creates a backup of the current database.
#
backupDatabase() {
  echo "Creating backup: '$BACKUP_FILE'."
  sudo -u postgres -i \
    /usr/bin/pg_dump "$DB_NAME" > "$BACKUP_FILE"
  chown argumenta-backup:argumenta-backup "$BACKUP_FILE"
  chmod 0660 "$BACKUP_FILE"
}

#
# Creates a daily backup for current weekday.
#
createDaily() {
  local day=$( date +%a )
  local dailyFile="${DAILY_DIR}/${BACKUP_NAME}.${day}"
  find "$DAILY_DIR" -maxdepth 1 -name "*.$day" -print0 | xargs -r -0 rm
  echo "Creating daily backup: '${dailyFile}'."
  sudo -u argumenta-backup \
    cp -p "$BACKUP_FILE" "$dailyFile"
}

#
# Creates a weekly backup on Sunday for current week.
#
createWeekly() {
  if [[ `date +%a` == 'Sun' ]]; then
    local week=$(( 1 + 10#`date +%W` % 4 ))
    local weekName="week${week}"
    local weeklyFile="${WEEKLY_DIR}/${BACKUP_NAME}.${weekName}"
    find "$WEEKLY_DIR" -maxdepth 1 -name "*.$weekName" -print0 | xargs -r -0 rm
    echo "Creating weekly backup: '${weeklyFile}'."
    sudo -u argumenta-backup \
      cp -p "$BACKUP_FILE" "$weeklyFile"
  fi
}

#
# Creates a monthly backup on the 1st for current month.
#
createMonthly() {
  if (( 10#`date +%d` == 1 )); then
    local month=$( date +%b )
    local monthlyFile="${MONTHLY_DIR}/${BACKUP_NAME}.${month}"
    find "$MONTHLY_DIR" -maxdepth 1 -name "*.$month" -print0 | xargs -r -0 rm
    echo "Creating monthly backup: '${monthlyFile}'."
    sudo -u argumenta-backup \
      cp -p "$BACKUP_FILE" "$monthlyFile"
  fi
}

#
# Removes the backup after creating daily, weekly, and monthly snapshots.
#
cleanup() {
  rm "$BACKUP_FILE"
}

#
# Main script.
#
main() {
  getOpts "$@"
  umask 0007
  createBackupDirs
  backupDatabase
  createDaily
  createWeekly
  createMonthly
  cleanup
}

# Let's do this!
main "$@"
