#!/usr/bin/env bash

# Unset any existing BF3_BOOTSTRAPS as this is a
# framework environment activation
if [ ! -z BF3_BOOTSTRAP ]; then
    unset BF3_BOOTSTRAP
fi

# Include common activqtion helpers
source "$(dirname $(readlink -f ${BASH_SOURCE}) )/common.sh"

# If a BF3 environment is active remove all the previous environment locations
# from the system path before unsetting it
if [ ! -z BF3_PATH ]; then
    export PATH=$(bf3.bootstrap.removePaths)
fi
unset BF3_PATH
# Add this environment to the BF3_PATH
export BF3_PATH=$(bf3.bootstrap.addToPath "$BF3_PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)")

# As this is a framework activation set the bootstrap.sh path to this env's one
export BF3_BOOTSTRAP="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/../bootstrap.sh)"

# This is the path of the BF3 environment which was activated, even when additional
# environments are added
export BF3_ACTIVE_PATH="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)"

# This sets the path for this BF3 base framework locations
export BF3_FW_PATH="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)"

# Add this environment's install_hooks directory to the system path so this environment's
# commands can be executed from anywhere.
# NOTE: if another environment is added and a command has an identical name the most
# recently one added will take precedence
export PATH=$(bf3.bootstrap.addToPath "$PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)/install_hooks")

bf3.bootstrap.printSummary
