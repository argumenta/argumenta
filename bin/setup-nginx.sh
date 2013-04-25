#!/bin/bash

# setup-nginx.sh
# Sets up nginx configuration files.

# This script's real path.
SCRIPT_FILE=$(readlink -f "$0")

# Source directory for Argumenta.
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)

# SSL directory.
SSL_DIR="/etc/argumenta/ssl"

# Nginx config defaults file.
DEFAULT_FILE="/etc/argumenta/nginx.conf.defaults"

# Nginx config file.
CONFIG_FILE="/etc/argumenta/nginx.conf"

# Nginx configuration template.
NGINX_CONFIG=$(cat <<-END

	user www-data www-data;

	events {
	  worker_connections 4096;
	}

	http {
	  include mime.types;

	  upstream node_app {
	    server 127.0.0.1:8080;
	  }

	  server {
	    server_name argumenta.io;
	    listen 443;

	    ssl on;
	    ssl_certificate ${SSL_DIR}/argumenta.crt;
	    ssl_certificate_key ${SSL_DIR}/argumenta.key;

	    location / {
	      proxy_read_timeout 300;
	      proxy_pass http://node_app;
	      proxy_set_header Host \$host;
	      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
	      proxy_set_header X-Forwarded-HTTPS 1;
	    }

	    # Serve static files directly.
	    location ~* ^/(images|javascripts|stylesheets|widgets)/ {
	      root ${SOURCE_DIR}/public;
	    }
	  }
	}

END
)

#
# Creates Nginx config and defaults.
#
createNginxConfig() {
  echo "Creating Nginx config."
  echo "$NGINX_CONFIG" > "$DEFAULT_FILE"
  cp -n "$DEFAULT_FILE" "$CONFIG_FILE"
}

#
# Main script.
#
main() {
  createNginxConfig
}

# Let's do this!
main "$@"
