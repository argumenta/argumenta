#!/bin/bash

# argumenta.sh
# Starts the Argumenta app.

SOURCE_DIR=$(readlink -f `dirname "$0"`/..)
APP="$SOURCE_DIR"/app/index.js

node "$APP"
