resource.relative '@rel==./templates/module.sh' into '@this'
resource.relative '@rel==./templates/docs/module.sh.mo' into '@this'
resource.relative '@rel==./templates/docs/description.txt' into '@this'
resource.relative '@rel==./templates/docs/description.bml' into '@this'

@namespace

createCmd::args() {
    parameters.add --key 'namespace' \
        --namespace '@this.createCmd' \
        --name 'Namespace' \
        --alias '--namespace' \
        --alias '-n' \
        --desc 'The new command namespae' \
        --required '1' \
        --has-value 'y'
}


createCmd() {
    logger.info --message \
        "Creating command..."
    @=>params

    local nsPath
    string.replace nsPath '.'  '/' "@params[namespace]"

    local fullpath="${BF3_ACTIVE_PATH}/modules/${nsPath}"
    logger.info --message \
        "Target path is ${fullpath}"

    local modulePath="${fullpath}/module.sh"
    [ -f "${modulePath}" ] && {
        logger.error --message \
            "A module file already exists at path: ${modulePath}"
        logger.die
    }
    mkdir -p "${fullpath}"
    local docsPath="${fullpath}/docs"

    echo "$(@this.resource.get './templates/module.sh')" > "${modulePath}"

    mkdir -p "${docsPath}"
    echo "$(@this.resource.get './templates/docs/module.sh.mo')" > "${docsPath}/module.sh"
    echo "$(@this.resource.get './templates/docs/description.txt')" > "${docsPath}/description.txt"
    echo "$(@this.resource.get './templates/docs/description.bml')" > "${docsPath}/description.bml"

    logger.info --message \
        "New command created at ${modulePath}"

    logger.info --message \
        "You can execute you new command by running:"
    logger.info --message \
        "bf3 --run @params[namespace]"

}



main::args() {
    parameters.add --key 'create' \
        --namespace '@this.main' \
        --name 'Create' \
        --alias '--create' \
        --alias '-c' \
        --desc 'Create a new command.' \
        --default '0' \
        --has-value 'n' \
        --type 'switch' \
        --includes '@this.createCmd::namespace' \
        --required '1'
   
    @this.createCmd::args
}

main() {
    @=>*params
    if [ "@params[create]" == '1' ]; then
        @this.createCmd "${unknown[@]}"
    fi
}