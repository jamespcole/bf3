resource.relative '@rel==templates/info.bml' into '@this'

@namespace

__init() {
    @this.args
}
args() {
    parameters.add --key 'showHelp' \
        --namespace 'global' \
        --name 'Show Help' \
        --alias '--help' \
        --desc 'Print help for the command.' \
        --has-value 'm' \
        --priority '2' \
        --callback '@this.printHelp'
}

printHelp() {
    @this.printCommandInfo "$@"

    @this.printArgs "$@"
    exit
}

# printArgs::precache() {
printArgs::precache() {
    if import.isModeuleInitialized 'bml'; then
        @this.printArgsBml "$@"
    else
        @this.printArgsPlain "$@"
    fi
}

printArgsBml() {
    local argHelp="{{b:br}}{{#b:h5}}Arguments{{/b:h5}}{{b:br}}{{b:br}}"
    local argKey
    for argKey in "${paramKeys[@]}"; do
        local keyPrefix="${argKey}>>"
        if [ "@globals['isBuilding']" == true ] && [ "${parameterDefinitions[${keyPrefix}namespace]}" == 'run' ]; then
            continue
        fi

        if [ "@globals['commandNamespace'].main" != "${parameterDefinitions[${keyPrefix}namespace]}" ] && [ "${parameterDefinitions[${keyPrefix}namespace]}" != 'global' ]; then
            continue
        fi

        local aliases="${parameterDefinitions[${keyPrefix}alias_list]}"
        local name="${parameterDefinitions[${keyPrefix}name]}"
        local desc="${parameterDefinitions[${keyPrefix}desc]}"
        local type="${parameterDefinitions[${keyPrefix}type]}"
        local typeInfo=''
        if [ "$type" == 'enum' ]; then
            local enumList="${parameterDefinitions[${keyPrefix}enum-value_list]}"
            typeInfo="{{b:in}}{{#b:d}}Must be one of the values: ${enumList}{{/b:d}}{{b:br}}"
        fi


        argHelp="${argHelp}{{#b:b}}${aliases}{{/b:b}}, {{#b:u}}${name}{{/b:u}}{{b:br}}"
        argHelp="${argHelp}{{b:in}}{{#b:d}}${desc}{{/b:d}}{{b:br}}"
        argHelp="${argHelp}${typeInfo}"
        argHelp="${argHelp}{{b:br}}"

    done
    bml.print --text \
        "${argHelp}"
}

printArgsPlain() {
    local argHelp="\nArguments\n\n"
    local argKey
    for argKey in "${paramKeys[@]}"; do
        local keyPrefix="${argKey}>>"
        if [ "@globals['isBuilding']" == true ] && [ "${parameterDefinitions[${keyPrefix}namespace]}" == 'run' ]; then
            continue
        fi

        if [ "@globals['commandNamespace'].main" != "${parameterDefinitions[${keyPrefix}namespace]}" ] && [ "${parameterDefinitions[${keyPrefix}namespace]}" != 'global' ]; then
            continue
        fi

        local aliases="${parameterDefinitions[${keyPrefix}alias_list]}"
        local name="${parameterDefinitions[${keyPrefix}name]}"
        local desc="${parameterDefinitions[${keyPrefix}desc]}"
        local type="${parameterDefinitions[${keyPrefix}type]}"
        local typeInfo=''
        if [ "$type" == 'enum' ]; then
            local enumList="${parameterDefinitions[${keyPrefix}enum-value_list]}"
            typeInfo="Must be one of the values: ${enumList}\n"
        fi


        argHelp="${argHelp}${aliases}, ${name}\n"
        argHelp="${argHelp}${desc}\n"
        argHelp="${argHelp}${typeInfo}\n"

    done
    echo "${argHelp}"
}

# printCommandInfo::precache() {
printCommandInfo::precache() {
    @this.getCommandInfo "$@"
}

getCommandInfo() {
    if import.isModeuleInitialized 'bml'; then
        @this.getCommandInfoBml "$@"
    else
        @this.getCommandInfoPlain "$@"
    fi
}

getCommandInfoPlain() {
    local -A templateData

    templateData[commandName]="@globals[commandName]"
    templateData[buildDate]="@globals[buildDate]"
    templateData[commandNamespace]="@globals[commandNamespace]"
    templateData[description]=''
    import.functionExists "@globals[commandNamespace].docs.description" && {
        templateData[description]=$(@globals[commandNamespace].docs.description)
    }

    echo "${templateData[commandName]}"
    echo "${templateData[description]}\n"
    echo "Info"
    echo "\tBuilt On: ${templateData[buildDate]}"
    echo "\tModule: ${description[commandNamespace]}"
    
}

getCommandInfoBml() {
    local -A templateData

    templateData[commandName]="@globals[commandName]"
    templateData[buildDate]="@globals[buildDate]"
    templateData[commandNamespace]="@globals[commandNamespace]"
    templateData[description]=''
    import.functionExists "@globals[commandNamespace].docs.description" && {
        templateData[description]=$(@globals[commandNamespace].docs.description)
    }
    import.functionExists "@globals[commandNamespace].docs.descriptionBml" && {
        local bmlDesc="$(@globals[commandNamespace].docs.descriptionBml)"
        templateData[description]="${bmlDesc}"
    }

    bml.print --text \
        "$(@this.resource.get 'templates/info.bml')"
}
