#!/bin/bash

# setup-config.sh
# Sets up deployment config files for further customization.

# Script dir
BASEDIR=$(dirname "$0")

# Source path
SRC=$(dirname "$BASEDIR")

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
    echo "TEST_ONLY: $TEST_ONLY"
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
# Main program.
#
main() {
  getOpts "$@"

  # Copy the config for each mode and generate an appSecret
  for mode in development testing production staging; do
    local config="${SRC}/config/modes/${mode}.coffee"
    local deploy="${SRC}/config/deploy/${mode}.coffee"

    if [[ ! -f "$deploy" ]]; then
      local secret=$(generateAppSecret);
      run cp "$config" "$deploy"
      run sed -i -r "s/^( +)([^ #])/\1# \2/" "$deploy"
      run sed -i -r "s/# (appSecret.*)SECRET(.*)/\1${secret}\2/" "$deploy"
    fi
  done
}

# Let's do this!
main "$@"
