#!/usr/bin/env bash

source "$(dirname $(readlink -f ${BASH_SOURCE}) )/common.sh"
export BF3_PATH=$(bf3.bootstrap.addToPath "$BF3_PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)")

source "$(dirname $(readlink -f ${BASH_SOURCE}) )/../modules/import.sh"
export BF3_BOOTSTRAP="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/../bootstrap.sh)"

export PATH=$(bf3.bootstrap.addToPath "$PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)/install_hooks")

# This sets the path for this BF3 base framework locations
export BF3_FW_PATH="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)"
