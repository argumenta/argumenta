#!/bin/bash

# argumenta.sh
# Starts the Argumenta app.

SCRIPT_FILE=$(readlink -f "$0")
SOURCE_DIR=$(readlink -f `dirname "$SCRIPT_FILE"`/..)
APP="$SOURCE_DIR"/app/index.js

node "$APP"
