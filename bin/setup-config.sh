#!/bin/bash

# setup-config.sh
# Sets up deployment config files for further customization.

# This script's real path.
SCRIPT_FILE=$(readlink -f "$0")

# This script's source directory.
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)

# Debug mode
DEBUG=0

# Test only mode
TEST_ONLY=0

#
# Prints usage information.
#
usage() {
  cat <<-End

  Usage: ./setup-config.sh [options]

  Options:
    -d, --debug : Show additional debug info.
    -h, --help  : Show this usage info.
    -t, --test  : Run in test-only mode.

End
}

#
# Runs the given command, or just prints if test mode active.
#
run() {
  if [[ $TEST_ONLY -eq 1 ]]; then
    echo "would run: $@"
  else
    "$@"
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
      -t | --test   ) TEST_ONLY=1; shift ;;
      *             ) shift ;;
    esac
  done

  if [[ $DEBUG -eq 1 ]]; then
    echo "Debug mode enabled."
    set -x
  fi
}

#
# Generates an appSecret as a 60 character random hex string.
#
generateAppSecret() {
  local secret=`node -p -e "require('crypto').randomBytes(30).toString('hex');"`
  echo "$secret"
}

#
# Renders config file from template and given params.
#
renderConfig() {
  local secret="$1"
  local user="$2"
  local db="$3"
  cat <<-END
	{
	  "appSecret":   "${secret}",
	  "postgresUrl": "postgres://${user}:PASSWORD@localhost:5432/${db}"
	}
END
}

#
# Main program.
#
main() {
  getOpts "$@"

  run echo "Initializing config/deploy"
  mkdir -p "${SOURCE_DIR}/config/deploy"

  # Copy the config for each mode and generate an appSecret
  for mode in development testing staging production; do
    local config="${SOURCE_DIR}/config/modes/${mode}.json"
    local deploy="${SOURCE_DIR}/config/deploy/${mode}.json"

    if [[ ! -f "$deploy" ]]; then
      run echo "Creating '$deploy'"
      run cp "$config" "$deploy"

      if [[ $mode == 'production' ]]
      then local db="argumenta"
      else local db="argumenta_${mode}"
      fi

      local user="$db"
      local secret=$(generateAppSecret)
      local config=$(renderConfig $secret $user $db)
      echo "$config" > "$deploy"
    else
      run echo "Found '$deploy'"
    fi
  done

  run echo "Done!"
}

# Let's do this!
main "$@"
