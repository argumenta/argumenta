#!/bin/bash

# setup-server.sh
# Setup a server install of Argumenta.

# Exit if any command exits with non-zero status.
set -e

# This script's real path.
SCRIPT_FILE=$(readlink -f "$0")

# This script's source directory.
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)

# The target install directory.
INSTALL_DIR='/usr/local/argumenta'

# The deployment config directory.
CONFIG_DIR='/etc/argumenta'

# The upstart config file.
UPSTART_CONFIG_FILE='/etc/init/argumenta.conf'

#
# Upstart config for the `argumenta` service.
#
UPSTART_CONFIG=$(cat <<-"END"

	description "Argumenta (Node.js)"
	author "Argumenta.io"

	start on (local-filesystems and net-device-up IFACE!=lo)
	stop on runlevel [016]

	respawn
	respawn limit 10 5  # Default respawns per second.

	script
	  if [ -f /usr/bin/node ]; then
	    NODE=/usr/bin/node
	  else
	    NODE=`which node`
	  fi

	  export HOME="/home/argumenta"
	  echo $$ > /var/run/argumenta.pid
	  exec sudo -u argumenta \
	    NODE_ENV='production' CONFIG_DIR='/etc/argumenta' \
	    "$NODE" /usr/local/argumenta/app \
	    1>> /var/log/argumenta.log \
	    2>> /var/log/argumenta.err
	end script

END
)

#
# Adds an `argumenta` user account.
#
addUser() {
  echo "Adding 'argumenta' user account."
  adduser \
    --quiet \
    --system \
    --shell /bin/bash \
    --gecos 'Argumenta web app' \
    --group \
    --disabled-password \
    --home /home/argumenta \
    argumenta
}

#
# Installs the Argumenta app.
#
installApp() {
  echo "Installing app to '$INSTALL_DIR'."
  cp -a -T "$SOURCE_DIR" "$INSTALL_DIR"
  chown -R root:argumenta "$INSTALL_DIR"
  chmod -R 0740 "$INSTALL_DIR"
  chmod -R 0750 "${INSTALL_DIR}/bin"
  find "$INSTALL_DIR" -type d -print0 | xargs -0 chmod -R 0750
}

#
# Generates app config files.
#
genAppConfig() {
  echo "Generating app config."
  "$INSTALL_DIR"/bin/setup-config.sh > /dev/null
}

#
# Creates deployment config files.
#
createDeployConfig() {
  echo "Creating deploy config in '$CONFIG_DIR'."
  cp -a --no-clobber -T "${INSTALL_DIR}/config/deploy" "$CONFIG_DIR"
  chown -R root:argumenta "$CONFIG_DIR"
  chmod -R 0740 "$CONFIG_DIR"
  find "$CONFIG_DIR" -type d -print0 | xargs -0 chmod -R 0750
}

#
# Creates an Upstart config file.
#
createUpstartConfig() {
  echo "Creating Upstart config '$UPSTART_CONFIG_FILE'."
  echo "$UPSTART_CONFIG" > $UPSTART_CONFIG_FILE
  chmod 0644 $UPSTART_CONFIG_FILE
}

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
# Main script.
#
main() {
  getOpts "$@"
  addUser
  installApp
  genAppConfig
  createDeployConfig
  createUpstartConfig
  echo "Done!"
}

# Let's do this!
main "$@"
