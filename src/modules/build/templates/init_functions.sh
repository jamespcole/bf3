declare -A -g __import_INITED

import.initModule() {
    local __import_modName="$1"
    "${__import_modName}.init"
    if import.functionExists "${__import_modName}.__init"; then
        "${__import_modName}.__init"
    fi
    __import_INITED["${__import_modName}"]='1'
}
import.useModule() {
    local __import_modName="$1"
    if [[ ! ${__import_INITED["${__import_modName}"]+exists} ]]; then
        import.initModule "$__import_modName"
    else
        "${__import_modName}.init"
    fi
}
import.useModules() {
    local moduleName
    for moduleName in "${__import_DEPENDENCIES[@]}"
    do
        # Replace > with underscore to access namespace
        import.useModule "${moduleName//>/_}"
    done
}
import.functionExists() {
    declare -f -F $1 > /dev/null
    return $?
}


cmd.run.loadArgs() {
    logger.args
    # Load main function args for the module if they exist
    if import.functionExists "${globals[commandNamespace]}.main::args"; then
        "${globals[commandNamespace]}.main::args"
    fi
    local -A params
    local -a unknown
    parameters.load --namespace 'global' --ignore-unknown true --args "$@"
    declare -A -g globals
    for paramValKey in "${!params[@]}"; do
        globals["${paramValKey}"]="${params[${paramValKey}]}"
    done
    logger.processStartupArgs
    "${globals[commandNamespace]}.main" "${unknown[@]}"
}
