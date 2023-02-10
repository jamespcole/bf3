import.require 'params'

@namespace
@create{}(@this.settings)
@set(@this.settings['print_prefix'])='1'
    # declare -A -g __logger_formatted_SETTINGS
    # __logger_formatted_SETTINGS['print_prefix']='1'

@this[prefixSep]=': '

@create{}(@this.prefixes)
@set(@this.prefixes['INFO'])="INFO@this[prefixSep]"
@set(@this.prefixes['ERROR'])="ERROR@this[prefixSep]"
@set(@this.prefixes['WARNING'])="WARNING@this[prefixSep]"
@set(@this.prefixes['DEBUG'])="DEBUG@this[prefixSep]"

@create{}(@this.theme)
@set(@this.theme['HR'])="-----------------------------------------------"

    create() {
        local -A __params
        params.get "$@"
        local __key="${__params['id']}>>"
        local __param
        for __param in "${!__params[@]}"; do
            local __p_key="${__key}${__param}"
            @set(@this.settings["${__p_key}"])='1'
            # __logger_formatted_SETTINGS["${__p_key}"]="${__params[$__param]}"
        done
    }
    processStartupArgs() {
        # if [ "${__args_VALS['logger_decoration']}" -gt 1 ]; then
        #     __logger_formatted_SETTINGS['print_prefix']='0'
        # fi
        # bml.loadTheme
        # @set(@this.prefixes['INFO'])=$(bml.print --text "{{#b:info}}INFO{{/b:info}}@this[prefixSep]")
        # @set(@this.prefixes['ERROR'])=$(bml.print --text "{{#b:danger}}ERROR{{/b:danger}}@this[prefixSep]")
        # @set(@this.prefixes['WARNING'])=$(bml.print --text "{{#b:warning}}{{#b:icon}}warning{{/b:icon}} WARNING{{/b:warning}}@this[prefixSep]")
		# @set(@this.prefixes['DEBUG'])=$(bml.print --text "DEBUG@this[prefixSep]")
        # @set(@this.theme['HR'])=$(bml.print --text "{{#b:hr}}")
        return 0
    }
    printCommandStart() {
        @this.print \
            --message "Starting..." \
            --prefix 'SCRIPT'
    }
    printCommandEnd() {
        @this.print \
            --message "Finished" \
            --prefix 'SCRIPT'
    }
    debug() {
        local -A __params
        __params['message']=''
        params.get "$@"
        @this.print --message "${__params['message']}" \
            --prefix "@get(@this.prefixes['DEBUG'])"
    }
    info() {
        local -A __params
        __params['message']=''
        params.get "$@"
        @this.print --message "${__params['message']}" \
            --prefix "@get(@this.prefixes['INFO'])"
    }
    success() {
        local -A __params
        __params['message']=''
        params.get "$@"
        @this.print --message "${__params['message']}" \
            --prefix 'SUCCESS'
    }
    warning() {
        local -A __params
        __params['message']=''
        params.get "$@"
        @this.print --message "${__params['message']}" \
            --prefix "@get(@this.prefixes['WARNING'])"
    }
    error() {
        local -A __params
        __params['message']=''
        params.get "$@"
        @this.print --message "${__params['message']}" \
            --prefix "@get(@this.prefixes['ERROR'])"
    }
    stackTrace() {
        @this.print \
            --message '-------------- Stack Trace -----------------' \
            --prefix 'TRACE'
        # local frame=0
        # local moreFrames=0
        # while caller $frame; do
        #     # local frameStr
        #     # frameStr="$(caller $frame)"
        #     # moreFrames="$?"
        #     # @this.print \
        #     #     --message "${frameStr}" \
        #     #     --prefix 'TRACE'
        #
        #     ((frame++));
        # done
        # echo "$*"

        if [ ${#FUNCNAME[@]} -gt 2 ]; then
            local endIndex=3
            echo "Call tree:"
            local i
            for ((i=${#FUNCNAME[@]}-2;i>${endIndex}-1;i--)); do
                local callNum
                local funcName="${FUNCNAME[$i]}"
                local calledBy="${FUNCNAME[$i+1]}"
                let callNum=i-1
                echo " ${callNum}: ${calledBy} == Called ==> ${funcName}(...)"
                echo "     => ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]}"
                if [ "${calledBy}" == '' ]; then
                    continue
                fi
                [ -z "${__import_FUNC_SOURCE[${calledBy}]}" ] || {
                    echo "${__import_FUNC_SOURCE[${calledBy}]}"
                }
            done


            @this.error "$@"
            local endFunc="${FUNCNAME[${endIndex}]}"
            echo "in function '${endFunc}'"
            [ -z "${__import_FUNC_SOURCE[${endFunc}]}" ] || {
                echo "${__import_FUNC_SOURCE[${endFunc}]}"
            }
            [ -z "${__import_FUNC_SOURCE[${endFunc}]}" ] && {
                echo "${BASH_SOURCE[${endIndex}]}"
            }
        fi

        # @this.print \
        #     --message "$*" \
        #     --prefix 'TRACE'
    }
    die() {
        echo "ERROR: ${1}"
        @this.stackTrace "$@"
    }
    beginTask() {
        local -A __params
        __params['message']=''
        __params['title']=''
        params.get "$@"

        @this.print \
            --message \
            "BEGIN ${__params['title']} - ${__params['message']}" \
            --prefix 'TASK'
    }
    endTask() {
        local -A __params
        __params['message']=''
        __params['title']=''
        __params['success']=''
        params.get "$@"

        @this.print \
            --message \
            "END ${__params['title']} - ${__params['message']}" \
            --prefix 'TASK'
    }
    step() {
        local -A __params
        __params['message']=''
        __params['number']=0
        __params['total']=0
        params.get "$@"
        @this.print \
            --message "${__params['number']}/${__params['total']} - ${__params['message']}"
    }
    printLoop() {
        local __line
        local __is_loading='0'
        while read __line; do
            echo "$__line"
        done
    }
    print() {
        local -A __params
        __params['message']=''
        __params['prefix']=''
        __params['no-newline']='0'
        params.get "$@"

        local __log_line="${__params['message']}"
        # echo -e "${__params['message']}" | fmt -w 120 -s | while read  __log_line; do
            if [ "@get(@this.settings['print_prefix'])" != '0' ]; then
                __log_line="${__params['prefix']}${__log_line}"
            fi
            if [ "${__params['no-newline']}" == '0' ]; then
                echo -e "${__log_line}"
            else
                echo -en "${__log_line}"
            fi
        # done
    }
    hr() {
        echo "@get(@this.theme['HR'])"
    }
    br() {
        echo ""
    }
    supportsMarkup() {
        return 0
    }
