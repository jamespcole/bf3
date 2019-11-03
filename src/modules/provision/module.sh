#!/usr/bin/env bash

@namespace

isInstalled() {
    if [ $(which "$1" | wc -l) == '0' ]; then
        logger.info --message \
            "Command \"${1}\" is not installed" \
            --verbosity 2
        return 1
    fi
    return 0
}

require() {
    local itemName="$1"
    shift;
    if ! import.functionExists "provision.${itemName}.require"; then
        logger.error --message \
            "The function 'provision.${itemName}.require' was not found,' \
                + ' did you forget to import the namespace 'provision.${itemName}'?"
        return 1
    fi
    "provision.${itemName}.require" "$@"
}

isPackageInstalled() {
    if [ $(apt-cache policy "$1" | grep 'Installed: (none)' | wc -l) != '0' ]; then
        logger.info --message \
            "Package \"${1}\" is not installed" \
            --verbosity 2
        return 1
    fi
    logger.info --message \
        "Package \"${1}\" is already installed" \
        --verbosity 2
    return 0
}

isPpaInstalled() {
    local ppaName="${1}"

    if [ ! -d /etc/apt/sources.list.d ]; then
        grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep -q "${ppaName}" && {
            return 0
        }
    else
        grep ^ /etc/apt/sources.list | grep -q "${ppaName}" && {
            return 0
        }
    fi

    return 1
}
