#!/usr/bin/env bash
import.require 'params'
# Testing remove this later
# import.require 'logger.handlers.formatted'
import.require 'logger.handlers.basic'
# import.require 'logger.handlers.fancy'

@namespace

declare -A -g __logger_LEVEL
__logger_LEVEL['DEBUG']=1
__logger_LEVEL['INFO']=2
__logger_LEVEL['WARN']=3
__logger_LEVEL['ERROR']=4
__logger_LEVEL['CRIT']=5

@this[debug]=1
@this[info]=2
@this[warning]=3
@this[error]=4


declare -A -g __logger_SETTINGS
# Higher == more verbose
__logger_SETTINGS['VERBOSITY']=3
__logger_SETTINGS['WIDTH']=80
__logger_SETTINGS['in-loop']='0'
__logger_SETTINGS['force-verbose']='0'
__logger_SETTINGS['decor']='0'
__logger_SETTINGS['force-decor']='0'
__logger_SETTINGS['hide-prefix']='0'
__logger_SETTINGS['force-hide-prefix']='0'


declare -A -g __logger_HANDLERS

# import.useModule 'logger.handlers.formatted'
# import.useModule 'logger.handlers.fancy'
# __logger_HANDLERS['console']='logger.handlers.formatted'
__logger_HANDLERS['console']='logger.handlers.basic'
# __logger_HANDLERS['console']='logger.handlers.fancy'
# import.useModule 'params'

args() {
    parameters.add --key 'logLevel' \
        --namespace 'global' \
        --name 'Log Level' \
        --alias '--log-level' \
        --desc 'The level of logging to output during execution.' \
        --default 'info' \
        --enum-value 'debug' \
        --enum-value 'info' \
        --enum-value 'warning' \
        --enum-value 'error' \
        --type 'enum'

	parameters.add --key 'logFormatter' \
        --namespace 'global' \
        --name 'Log Formatter' \
        --alias '--log-fmt' \
        --desc 'The log formatter to use.' \
        --default 'logger.handlers.formatted' \
        --has-value 'y'
}
#
# argsOld() {
#     args.add --key 'logger_monochrome' \
#         --name 'Monochrome' \
#         --alias '--mono' \
#         --alias '-M' \
#         --desc 'Do not use colours when printing to the console.' \
#         --has-value 'n' \
#         --type 'switch'
#
#     args.add --key 'logger_verbose' \
#         --name 'Verbose' \
#         --alias '--verbose' \
#         --alias '-v' \
#         --desc 'Print verbose output.' \
#         --has-value 'm' \
#         --default '0'
#
#     args.add --key 'logger_decoration' \
#         --name 'Output Decoration' \
#         --alias '--decor' \
#         --alias '-D' \
#         --desc 'The amount of formatting to be applied to output.  0 - 4, where 0 is no restriction and 4 is as little formatting as possible.' \
#         --has-value 'y' \
#         --default "${__logger_SETTINGS['decor']}" \
#         --callback 'logger.decorationCallback' \
#         --priority '2'
#
#     args.add --key 'logger_prefix' \
#         --name 'Hide Prefix' \
#         --alias '--hide-prefix' \
#         --desc 'Force logger to not prefix output for each line' \
#         --has-value 'n' \
#         --default "${__logger_SETTINGS['hide-prefix']}"
# }
processStartupArgs() {
    "${__logger_HANDLERS['console']}.processStartupArgs" "$@"
}
setFormatter() {
	local -A __params
	__params['namespace']=''
	params.get "$@"
	import.isModeuleInitialized "${__params['namespace']}" && {
		__logger_HANDLERS['console']="${__params['namespace']}"
	}
	
}
setConsoleLogHandler() {
	local -A __params
	__params['namespace']=''
    __params['width']=80
    __params['use-colour']=1
    __params['allow-styles']=1
    __params['use-markup']=0
    __params['log-level']="${__logger_LEVEL['INFO']}"
    __params['verbosity']="${__logger_SETTINGS['VERBOSITY']}"
	params.get "$@"
    # probably already imported but this giarantees it
    # import.require "${__params['namespace']}"
    import.useModule "${__params['namespace']}"
    __logger_HANDLERS['console']="${__params['namespace']}"
	"${__logger_HANDLERS['console']}.create" "$@" --id 'console'
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'DEBUG'
}
printCommandStart() {
    if [ "${__logger_SETTINGS['decor']}" -lt 1 ]; then
        "${__logger_HANDLERS['console']}.printCommandStart" "$@"
    fi
}
printCommandEnd() {
    if [ "${__logger_SETTINGS['decor']}" -lt 1 ]; then
        "${__logger_HANDLERS['console']}.printCommandEnd" "$@"
    fi
}
debug() {
    local logLevel="@globals[logLevel]"
    if [ "@this[${logLevel}]" -gt "@this[debug]" ]; then
        return 0
    fi
	local -A __params
	__params['message']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.debug" "$@" --prefix 'DEBUG'
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'DEBUG'
}
info() {
	local -A __params
	__params['message']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.info" "$@" --prefix 'INFO'
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'INFO'
}
success() {
	local -A __params
	__params['message']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.success" "$@" --prefix 'SUCCESS'
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'INFO'
}
warning() {
	local -A __params
	__params['message']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.warning" "$@" --prefix 'WARNING'
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'WARNING'
}
error() {
	local -A __params
	__params['message']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.error" "$@" --prefix 'ERROR'
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'ERROR'
}
stackTrace() {
	local -A __params
	__params['message']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.stackTrace" "$@"
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'ERROR'
    exit 0
}
die() {
	local -A __params
	__params['message']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.die" "$@"
	# logger_base.print --message "${__params['message']}" \
	# 	--prefix 'ERROR'
    exit 0
}
beginTask() {
	local -A __params
	__params['message']=''
    __params['title']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.beginTask" "$@" --prefix 'TASK'
}
endTask() {
	local -A __params
	__params['message']=''
    __params['title']=''
    __params['success']=''
	params.get "$@"
	"${__logger_HANDLERS['console']}.endTask" "$@" --prefix 'TASK'
}
step() {
	local -A __params
	__params['message']=''
    __params['number']=0
    __params['total']=0
	params.get "$@"
	"${__logger_HANDLERS['console']}.step" "$@" --prefix 'STEP'
}
printLoop() {
    "${__logger_HANDLERS['console']}.printLoop" "$@"
}
print() {
	local -A __params
	__params['message']=''
	__params['prefix']=''
	params.get "$@"

	# local __log_line
	# echo "${__params['message']}" | fold -w 80 -s | while read  __log_line; do
	"${__logger_HANDLERS['console']}.print" "$@"
	# done
}
hr() {
    "${__logger_HANDLERS['console']}.hr" "$@"
}
br() {
    "${__logger_HANDLERS['console']}.br" "$@"
}
supportsMarkup() {
    "${__logger_HANDLERS['console']}.supportsMarkup" "$@"
    return "$?"
}
forceVerbose() {
	local __force="$1"
	if [ "$__force" == '0' ]; then
    	__logger_SETTINGS['force-verbose']='0'
	else
		__logger_SETTINGS['force-verbose']='1'
	fi
}
forceDecoration() {
    local __force_decor="$1"

	if [ "$__force_decor" != '' ]; then
        __logger_SETTINGS['decor']="${__force_decor}"
        __logger_SETTINGS['force-decor']="1"
        @this.processStartupArgs
	fi
}
decorationCallback() {
    if [ "${__logger_SETTINGS['force-decor']}" != '1' ]; then
        __logger_SETTINGS['decor']="${__args_VALS['logger_decoration']}"
        @this.processStartupArgs
    fi
    return "$?"
}
forceHidePrefix() {
    local __hide_prefix="$1"
    __logger_SETTINGS['hide-prefix']="${__hide_prefix}"
    __logger_SETTINGS['force-hide-prefix']="1"
    @this.processStartupArgs
}
