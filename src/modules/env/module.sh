resource.relative '@rel==templates/activate.sh' into '@this'
resource.relative '@rel==templates/add.sh' into '@this'
resource.relative '@rel==templates/libs.sh' into '@this'

@namespace

main::args() {
    parameters.add --key 'path' \
        --namespace '@this.main' \
        --name 'Create' \
        --alias '--create' \
        --alias '-c' \
        --desc 'Create a new bf3 environment at the specified path(defaults to .)' \
        --has-value 'm' \
        --required-unless '@this.main::info' \
        --excludes '@this.main::info' \
        --default "$(pwd)"

    parameters.add --key 'info' \
        --namespace '@this.main' \
        --name 'Show Info' \
        --alias '--info' \
        --alias '-i' \
        --desc 'Print information about the current bf3 environment.' \
        --required-unless '@this.main::path' \
        --excludes '@this.main::path' \
        --has-value 'n'
}

main() {
    @=>params
    if [ "@params[info>>specified]" == '1' ]; then
        @this.printSummary
    fi

    if [ "@params[path>>specified]" == '1' ]; then
        @this.makeEnv
    fi
}

printSummary() {
    echo "BF3 Environment Active"
	echo "Active Environment Path: '${BF3_ACTIVE_PATH}'"
	echo "Active Environment Bootstrap: '${BF3_BOOTSTRAP}'"
    echo "Base Framework Path: '${BF3_FW_PATH}'"
	echo "Active BF3 Paths:"
	local IFS=':'
	local -a appPaths
    read -r -a appPaths <<< "${BF3_PATH}"
	local appPath
    for appPath in "${appPaths[@]}"
    do
		echo "    ${appPath}"
	done
}

makeEnv() {
    logger.info --message "Creating new BF3 environment at '@params[path]'"
    mkdir -p "@params[path]"
    mkdir -p "@params[path]/env"
    mkdir -p "@params[path]/modules"
    mkdir -p "@params[path]/install_hooks"
    mkdir -p "@params[path]/module_libs"

    echo "$(@this.getActivateFile)" > "@params[path]/env/activate.sh"
    echo "$(@this.getAddFile)" > "@params[path]/env/add.sh"
    echo "$(@this.getLibsFile)" > "@params[path]/env/libs.sh"

    logger.info --message "To activate it run '. @params[path]/env/activate.sh'"
}

getAddFile() {
    local -A templateData
    templateData[baseFrameworkPath]="${BF3_FW_PATH}"
    mustache.compile \
        --template "$(@this.resource.get 'templates/add.sh')"
}


getActivateFile() {
    local -A templateData
    templateData[baseFrameworkPath]="${BF3_FW_PATH}"
    mustache.compile \
        --template "$(@this.resource.get 'templates/activate.sh')"
}

getLibsFile() {
    local -A templateData
    mustache.compile \
        --template "$(@this.resource.get 'templates/libs.sh')"
}
