import.require 'params'
import.require 'string'
import.require 'logger'

@namespace

__init() {
    # Holds the args definitions, name, key, required etc.
    declare -A -g parameterDefinitions
    # Holds the values of the arguments after parsing
    declare -A -g paramDefaults
    # Maps the switches, eg -n --new, to a particular argument key
    declare -A -g paramSwitches
    # A list of all the registered arguument keys
    declare -a -g paramKeys
    # A list of all the argument validation errors encountered
    declare -a -g paramErrors
    # For globally available values
    declare -A -g globals

    declare -A -g addedNameSpaces
    # A list of all the argument validation errors encountered
}

add() {
    local keySep='>>'
    local -A __params
    __params['key']= # The unique key for this arg
    __params['namespace']= # A namespace for isolating groups of parameters
    __params['name']='' # The name of the arg variable
    # __params['alias']='' # The alias, eg: --yourname or -x
    __params['desc']= # A description of the argument
    __params['required']='0' # If the arg is required
    # The arg type, value, switch, enum, file_exists, dir_exists
    # file, dir
    __params['type']='value'
    # Specifies if a value is expected, not expected or either.
    # y = Must have a value
    # n = Must not have a value
    # m = Maybe has a value
    __params['has-value']='m'
    # If == 1 this arguments callback function will be called before
    # failed validations are printed.
    __params['priority']='0'
    # The function that will be called when this argument is used.
    __params['callback']=
    params.get "$@"

    local -a arrTypes=('alias' 'excludes' 'includes' 'required-unless')
    arrTypes+=('enum-value')

    local parameterNamespace="${__params['namespace']}"
    local nsKey="${parameterNamespace}::${__params['key']}"
    # if ! @this.arrContains paramKeys[@] "${nsKey}"; then
    if [[ ! "${addedNameSpaces["${nsKey}"]+exists}" ]]; then
        paramKeys+=("${nsKey}")
        addedNameSpaces["${nsKey}"]=true
    fi
    local argPrefix="${nsKey}${keySep}"

    for paramKey in "${!__params[@]}"; do
        if ! @this.arrContains arrTypes[@] "${paramKey}"; then
            parameterDefinitions["${argPrefix}${paramKey}"]="${__params[$paramKey]}"
            # echo "${argPrefix}${paramKey} => ${parameterDefinitions[${argPrefix}${paramKey}]}"
        fi
    done

    paramDefaults["${nsKey}"]=
    # Indicates whether or not the arg was specified, defaul to 0 here
    # and then set to one when parsing if it is found
    paramDefaults["${nsKey}${keySep}specified"]=0

    local __pargs="$@"
    local __arr_name
    for __arr_name in "${arrTypes[@]}"; do
        parameterDefinitions["${argPrefix}${__arr_name}_list"]=""
        parameterDefinitions["${argPrefix}${__arr_name}__count"]=0
        local __param_key="${nsKey}"
        @this.parseArrayTypes "$__arr_name" "$@"
    done

    paramDefaults["${nsKey}"]="${parameterDefinitions[${argPrefix}default]}"

    # echo "-------------- arg defs -----------------"
    # for __arg in "${!parameterDefinitions[@]}"; do
    #     echo "key  : ${__arg}"
    #     echo "value: ${parameterDefinitions[$__arg]}"
    # done
    # echo "-----------------------------------------"

}
parseArrayTypes() {
    local varName="$1"
    shift;
    local argVar
    local isVal=0
    local sep=''
    local numName

    for argVar in "${@}"
    do

        if [ $isVal -eq 1 ]; then
            isVal=0
            if [ "$varName" == 'alias' ]; then
                paramSwitches["${argVar}__${parameterNamespace}"]="${__param_key}"
            fi
            parameterDefinitions["${argPrefix}${varName}_list"]="${parameterDefinitions["${argPrefix}${varName}_list"]}${sep}${argVar}"
            parameterDefinitions["${argPrefix}${numName}"]="${argVar}"
            sep=','
        elif [ "${argVar}" == "--${varName}" ]; then
            isVal=1
            local lenCount="${parameterDefinitions["${argPrefix}${varName}__count"]}"
            numName="${varName}<${lenCount}>"
            let parameterDefinitions["${argPrefix}${varName}__count"]=lenCount+1
        fi
    done
}

parse() {
    local -A __params
    local -a remainder
    __params['namespace']=
    __params['ignore-unknown']=false
    params.getUntil '--args' "${@}"

    local allowUnknown="${__params['ignore-unknown']}"
    local parameterNamespace="${__params['namespace']}"

    local keySep='>>'
    local __var
    local __val_key
    local varSwitch
    local __is_val=0

    for __var in "${remainder[@]}"
    do
        if [ "${__var::1}" == "-" ]; then
            __is_val=1
            varSwitch="${__var}"
            __val_key="${__var}__${parameterNamespace}"
            if [[ ! "${paramSwitches["${__val_key}"]+exists}" ]]; then
                if [ "${allowUnknown}" == false ]; then
                    paramErrors+=("Unknown argument \"${varSwitch}\"")
                fi
                unknown+=( "${__var}" )
            fi
            # else
                # unset unknown["${paramsCount}"]
            # fi
            local argKey=${paramSwitches[$__val_key]}

            __spec_key="${argKey}${keySep}specified"
            paramVals["${__spec_key}"]=1
        elif [ $__is_val -eq 1 ]; then
            __is_val=0
            if [[ ! "${paramSwitches["${__val_key}"]+exists}" ]]; then
                if [ "${allowUnknown}" == false ]; then
                    paramErrors+=("Unknown argument \"${varSwitch}\" passed a value of \"${__var}\"")
                fi
                unknown+=( "${__var}" )
            else
                paramVals["${paramSwitches[$__val_key]}"]="$__var"
            fi
            __val_key=''
        fi
        let paramsCount=paramsCount+1
    done
}

# Called before any other args processing for args
# with a priority of 2
processCallbacks() {
    local keySep='>>'
    local argKey
    for argKey in "${paramKeys[@]}"; do
        local keyPrefix="${argKey}${keySep}"
        local argSpecified="${paramVals[${keyPrefix}specified]}"
        local argPriority="${parameterDefinitions[${keyPrefix}priority]}"
        if [ "$argPriority" == '2' ] \
            && [ "$argSpecified" == '1' ]
        then
            local argCallbabck="${parameterDefinitions[${keyPrefix}callback]}"
            if [ ! -z "$argCallbabck" ]; then
                "$argCallbabck"
            fi
        fi
    done
}
validate() {
    local -A __params
    __params['namespace']=
    __params['ignore-unknown']=false
    params.getUntil '--args' "${@}"

    local parameterNamespace="${__params['namespace']}"

    local keySep='>>'
    local argKey
    for argKey in "${paramKeys[@]}"; do
        [ "${parameterDefinitions[${argKey}${keySep}namespace]}" == "${parameterNamespace}" ] && {
            @this.validateArg "${argKey}"
        }
    done

    if [ "${#paramErrors[@]}" -gt 0 ]; then
        for __arg_err in "${paramErrors[@]}"; do
            logger.error --message "$__arg_err"
        done
        # exit 1

        logger.hr
        logger.info --message \
            "To see a full list of options and more info use the '--help' argument"
        @this.die
    fi
    # echo "-------------- arg vals -----------------"
    # for __arg in "${!paramVals[@]}"; do
    #     echo "key  : ${__arg}"
    #     echo "value: ${paramVals[$__arg]}"
    # done
    # echo "-----------------------------------------"
}

loadParams() {
    local parameterNamespace="${FUNCNAME[1]}"
    @this.load --namespace "${parameterNamespace}" --args "$@"
}

load() {
    local -A __params

    __params['namespace']=
    __params['ignore-unknown']=false
    __params['skip-validation']=false
    params.get "${@}"
    local parameterNamespace="${__params['namespace']}"

    local -A paramVals
    for paramKey in "${!paramDefaults[@]}"; do
        # echo "${paramKey} => ${parameterDefinitions[${paramKey}]}"
        if string.startsWith "${parameterNamespace}::" "${paramKey}"; then
            paramVals["${paramKey}"]="${paramDefaults[$paramKey]}"

        fi
    done

    @this.parse "$@"
    @this.processCallbacks
    if [ ! "${__params['skip-validation']}" == true ]; then
        @this.validate "$@"
    fi

    for paramValKey in "${!paramVals[@]}"; do
        local normalised
        string.removePrefix normalised "${parameterNamespace}::" "${paramValKey}"
        params["${normalised}"]="${paramVals[${paramValKey}]}"
    done
}



die() {
    if [ "@globals[built]" == true ]; then
        exit 1
    fi
    echo "-------------- Stack Trace -----------------"
    local frame=0
    while caller $frame; do
        ((frame++));
    done
    echo "$*"
    exit 1
}

validateArg() {
    local argKey="$1"
    local keySep='>>'
    local keyPrefix="${argKey}${keySep}"
    local hasValue=${parameterDefinitions[${keyPrefix}has-value]}
    local argName="${parameterDefinitions[${keyPrefix}name]}"
    local aliasList="${parameterDefinitions[${keyPrefix}alias_list]}"
    local typeKey="${argKey}${keySep}type"
    local argType=${parameterDefinitions[${typeKey}]}
    local argSpecified="${paramVals[${keyPrefix}specified]}"
    local argRequired="${parameterDefinitions[${keyPrefix}required]}"
    local argDefault="${parameterDefinitions[${keyPrefix}default]}"

    local argPriority="${parameterDefinitions[${keyPrefix}priority]}"
    if [ "$argPriority" == '1' ] \
        && [ "$argSpecified" == '1' ]
    then
        local argCallbabck="${parameterDefinitions[${keyPrefix}callback]}"
        if [ ! -z "$argCallbabck" ]; then
            "$argCallbabck"
        fi
    fi

    # Checks that the required arg was passed
    if [ "${argSpecified}" != '1' ] \
        && [ "${argRequired}" == '1' ]
    then
        paramErrors+=("The argument \"${argName}(${aliasList})\" is required")
    fi

    if [ "$hasValue" == 'y' ] \
        && [ -z "${paramVals[$argKey]}" ] \
        && [ "${argRequired}" == '1' ]
    then # Checks that args that require values when used have one
        paramErrors+=("The argument \"${argName}(${aliasList})\" requires a value")
    elif [ "$hasValue" == 'n' ] \
        && [ ! -z "${parameterDefinitions[$argKey]}" ]
    then # Checks that args that cannot have a value are empty
        paramErrors+=("The argument \"${argName}(${aliasList})\" can not have a value")
    elif [ "$hasValue" == 'y' ] \
        && [ -z "${paramVals[$argKey]}" ] \
        && [ "${argSpecified}" == '1' ]
    then
        paramErrors+=("The argument \"${argName}(${aliasList})\" requires a value")
    fi

    # Check for argument exclusions
    if [ "${argSpecified}" == '1' ]; then
        local loopCount=0
        local __arr_len="${parameterDefinitions[${keyPrefix}excludes__count]}"
        while [ $loopCount -lt $__arr_len ]; do
            local excludesKey="${parameterDefinitions[${keyPrefix}excludes<${loopCount}>]}"
            if [ "${paramVals[${excludesKey}${keySep}specified]}" == '1' ]; then
                local excludesName="${parameterDefinitions[${excludesKey}${keySep}name]}"
                local excludesAliases="${parameterDefinitions[${excludesKey}${keySep}alias_list]}"
                paramErrors+=("The argument \"${argName}(${aliasList})\" can not be used with \"${excludesName}(${excludesAliases})\"")
            fi
            let loopCount=loopCount+1
        done
    fi

    # Check for include argument requirements
    if [ "${argSpecified}" == '1' ]; then
        local loopCount=0
        local __arr_len="${parameterDefinitions[${keyPrefix}includes__count]}"
        while [ $loopCount -lt $__arr_len ]; do
            local excludesKey="${parameterDefinitions[${keyPrefix}includes<${loopCount}>]}"
            if [ "${paramVals[${excludesKey}${keySep}specified]}" == '0' ]; then
                local excludesName="${parameterDefinitions[${excludesKey}${keySep}name]}"
                local excludesAliases="${parameterDefinitions[${excludesKey}${keySep}alias_list]}"
                paramErrors+=("The argument \"${excludesName}(${excludesAliases})\" must also be specified when using \"${argName}(${aliasList})\"")
            fi
            let loopCount=loopCount+1
        done
    fi

    # echo "-------------- arg vals -----------------"
    # for __arg in "${!parameterDefinitions[@]}"; do
    #     echo "key  : ${__arg}"
    #     echo "value: ${parameterDefinitions[$__arg]}"
    # done
    # echo "-----------------------------------------"

    # Check for required unless
    local __arr_len="${parameterDefinitions[${keyPrefix}required-unless__count]}"
    if [ "${argSpecified}" != '1' ] \
            && [ "$__arr_len" -gt 0 ]
    then
        local loopCount=0
        local -a __req_unless_errs
        local invalid=1

        while [ $loopCount -lt $__arr_len ]; do
            local excludesKey="${parameterDefinitions[${keyPrefix}required-unless<${loopCount}>]}"
            if [ "${paramVals[${excludesKey}${keySep}specified]}" != '1' ]; then
                local excludesAliases="${parameterDefinitions[${excludesKey}${keySep}alias_list]}"
                local excludesName="${parameterDefinitions[${excludesKey}${keySep}name]}"
                __req_unless_errs+=("The argument \"${argName}(${aliasList})\" is required unless \"${excludesName}(${excludesAliases})\" is specified.")
            else
                invalid=0
            fi
            let loopCount=loopCount+1
        done

        if [ "$invalid" == '1' ]; then
            for __req_unless_err in "${__req_unless_errs[@]}"; do
                paramErrors+=("$__req_unless_err")
            done
        fi
    fi

    # If it's a switch and it is passed set the value to 1
    if [ "${argType}" == "switch" ] \
        && [ "${argSpecified}" == '1' ]
    then
        paramVals[$argKey]=1
    fi

    if [ "${argType}" == "file_exists" ] \
        && [ "${argSpecified}" == '1' ] \
        && [ ! -f "${paramVals[$argKey]}" ] \
        && [ ! -f "$(pwd)/${paramVals[$argKey]}" ];
    then
        paramErrors+=("The file \"${paramVals[$argKey]}\" specified for argument \"${argName}(${aliasList})\" could not be found.")
    fi

    if [ "${argType}" == "dir_exists" ] \
        && [ "${argSpecified}" == '1' ] \
        && [ ! -d "${paramVals[$argKey]}" ];
    then
        paramErrors+=("The directory \"${paramVals[$argKey]}\" specified for argument \"${argName}(${loopCountaliasList})\" could not be found.")
    fi

    # If it's a enum and it is passed check that it is in the list
    if [ "${argType}" == "enum" ] \
        && [ "${argSpecified}" == '1' ]
    then
        local __enum_count=0
        local __arr_len="${parameterDefinitions[${keyPrefix}enum-value__count]}"
        local enumFound=0
        while [ $__enum_count -lt $__arr_len ]; do
            local __enum_val="${parameterDefinitions[${keyPrefix}enum-value<${__enum_count}>]}"
            if [ "${__enum_val}" == "${paramVals[$argKey]}" ]; then
                enumFound=1
                break;
            fi
            let __enum_count=__enum_count+1
        done
        if [ "${enumFound}" == '0' ]; then
            local __enum_vals="${parameterDefinitions[${keyPrefix}enum-value_list]}"
            paramErrors+=("The argument \"${argName}(${aliasList})\" must be one of these values: \"${__enum_vals}\"")
        fi
    fi

    if [ "${argSpecified}" != '1' ] \
            && [ ! -z "$argDefault" ]
    then
        paramVals["$argKey"]="$argDefault"
    fi
}
isSpecified() {

    local -A __params
    __params['key']=
    params.get "$@"
    local argKey="${__params['key']}"
    local keySep='>>'
    local keyPrefix="${argKey}${keySep}"

    if [ "${paramVals[${keyPrefix}specified]}" == '1' ]; then
        return 0
    fi
    return 1
}
arrContains() {
    local haystack=${!1}
    local needle="$2"
    printf "%s\n" ${haystack[@]} | grep -q "^$needle$"
}
