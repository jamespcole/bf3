#!/usr/bin/env bash

source "$(dirname $(readlink -f ${BASH_SOURCE}) )/modules/import.sh"
declare -g BF3_EXECUTING_PATH="$(dirname $(readlink -f ${BASH_SOURCE[1]}) )"

import.init && import.__init

# import.require 'args'
import.require 'parameters'
import.require 'logger'
import.require 'docs.help'

bf3.cmd.bootstrap.init() {

    import.useModules
    logger.args

    bf3.cmd.bootstrap.run() {
        local cmdNameSpace="$1"
        # Remove the fist param which should be the command namespace
        shift;
        logger.processStartupArgs
        globals[built]=false
        globals[commandNamespace]="${cmdNameSpace}"
        globals[buildDate]="$(date '+%Y-%m-%d %H:%M:%S')"
        # If the main function of the module being run has args we need to load
        # them here so that they will appear in command help output.
        if import.functionExists "${cmdNameSpace}.main::args"; then
            "${cmdNameSpace}.main::args"
        fi

        local -A params
        local -a unknown
        parameters.load --namespace 'global' --ignore-unknown true --args "$@"
        for paramValKey in "${!params[@]}"; do
            globals["${paramValKey}"]="${params[${paramValKey}]}"
        done

        # parameters.validate --namespace 'run' --ignore-unknown true --args "$@"

        "${cmdNameSpace}.main" "${unknown[@]}"
    }

    bf3.cmd.bootstrap.build() {
        local cmdNameSpace="$1"
        shift;

        local buildStartMs=$(date +%s%3N)

        local installDir="${BF3_ACTIVE_PATH}/install_hooks"
        mkdir -p "${installDir}"
        local outputFile="${installDir}/${globals['commandName']}"
        echo "Beginning transpilation..."
        import.require "${cmdNameSpace}"

        echo "Writing transpiled functions..."
        declare -f > "${outputFile}"
        echo "Adding dependency list..."
        declare -p __import_DEPENDENCIES >> "${outputFile}"

        import.require 'build'
        import.useModule 'build'

        echo "Adding command init functions..."
        build.getInitFunctions >> "${outputFile}"

        echo "Running precacheable functions..."
        import.useModules
        if import.functionExists "${cmdNameSpace}.main::args"; then
            "${cmdNameSpace}.main::args"
        fi

        local funcName
        while read funcName
        do
            echo "Precaching '${funcName}'..."
            "${funcName}" > /dev/null
            echo "Adding the '${funcName}::cached' function to the build..."
            declare -f "${funcName}::cached" >> "${outputFile}"
        done < <( declare -F | grep '::precache$' | sed 's/^declare -f //' | sed 's/::precache$//')

        echo "Adding command execution functions..."
        echo 'import.useModules' >> "${outputFile}"
        echo 'globals[built]=true' >> "${outputFile}"
        echo "globals[commandNamespace]='${cmdNameSpace}'" >> "${outputFile}"
        echo "globals[commandName]='${globals[commandName]}'" >> "${outputFile}"
        echo "globals[buildDate]='$(date '+%Y-%m-%d %H:%M:%S')'" >> "${outputFile}"
        echo 'cmd.run.loadArgs "$@"' >> "${outputFile}"
        # echo "${cmdNameSpace}.main \"\$@\"" >> "${outputFile}"
        chmod +x "${outputFile}"

        local msTotal=$(($(date +%s%3N)-$buildStartMs))
        local timeStr="${msTotal}ms"
        if [ $msTotal -gt 1000 ]; then
            local seconds="$(($msTotal/1000))"
            local roundedMs=$(($seconds*1000))
            local remainderMs=$(($msTotal-$roundedMs))
            timeStr="${seconds}.${remainderMs} seconds"
        fi

        echo ""
        echo "Writing compiled source to '${outputFile}'."
        echo "Command '${globals[commandName]}' built successfuly in ${timeStr}."
        echo "You now execute the command by running: ${globals[commandName]}"
    }
}

bf3.cmd.run() {
    bf3.cmd.bootstrap.run "$@"
}

bf3.cmd.build() {
    bf3.cmd.bootstrap.build "$@"
}
