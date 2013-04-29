#!/bin/bash

# setup-nginx.sh
# Sets up nginx configuration files.

# This script's real path.
SCRIPT_FILE=$(readlink -f "$0")

# Source directory for Argumenta.
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)

# SSL directory.
SSL_DIR="/etc/argumenta/ssl"

# MIME types file.
MIME_FILE="/etc/argumenta/nginx.mime.types"

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
	  include /etc/argumenta/nginx.mime.types;

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
	      add_header Cache-Control public;
	    }
	  }
	}

END
)

MIME_TYPES='
types {
  text/html                             html htm shtml;
  text/css                              css;
  text/xml                              xml rss;
  text/mathml                           mml;
  text/plain                            txt;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  application/x-javascript              js;
  application/atom+xml                  atom;

  image/png                             png;
  image/svg+xml                         svg;
  image/tiff                            tif tiff;
  image/x-icon                          ico;
  image/x-ms-bmp                        bmp;

  application/java-archive              jar war ear;
  application/msword                    doc;
  application/pdf                       pdf;
  application/postscript                ps eps ai;
  application/rtf                       rtf;
  application/vnd.ms-excel              xls;
  application/vnd.ms-powerpoint         ppt;
  application/vnd.wap.xhtml+xml         xhtml;
  application/x-rar-compressed          rar;
  application/x-shockwave-flash         swf;
  application/x-x509-ca-cert            der pem crt;
  application/zip                       zip;

  application/octet-stream              bin exe dll;
  application/octet-stream              deb;
  application/octet-stream              dmg;
  application/octet-stream              eot;
  application/octet-stream              iso img;
  application/octet-stream              msi msp msm;

  audio/midi                            mid midi kar;
  audio/mpeg                            mp3;
  audio/x-realaudio                     ra;

  video/3gpp                            3gpp 3gp;
  video/mpeg                            mpeg mpg;
  video/quicktime                       mov;
  video/x-flv                           flv;
  video/x-mng                           mng;
  video/x-ms-asf                        asx asf;
  video/x-ms-wmv                        wmv;
  video/x-msvideo                       avi;
}
'

#
# Creates Nginx config and defaults.
#
createNginxConfig() {
  echo "Creating Nginx config."
  echo "$NGINX_CONFIG" > "$DEFAULT_FILE"
  cp -n "$DEFAULT_FILE" "$CONFIG_FILE"
}

#
# Creates a MIME types file.
#
createMimeTypes() {
  echo "Creating MIME types."
  echo "$MIME_TYPES" > "$MIME_FILE"
}

#
# Main script.
#
main() {
  createNginxConfig
  createMimeTypes
}

# Let's do this!
main "$@"
