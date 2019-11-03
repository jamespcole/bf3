
resource.init() {

    resource.includeFile() {
        local __file_path="$1"
        local __wrap_function="$2"

        local __wrapped_function
        if [ ! -f "$__file_path" ]; then
            echo "Failed to include file \"${__file_path}\""
            logger.die
            return 1
        fi
        local nl=$'\n'
        __wrapped_function="${__wrap_function}() {${nl}cat << 'EOF'${nl}$(cat ${__file_path})${nl}EOF${nl}}"
        eval "$(echo "${__wrapped_function}")"
    }
    resource.relative() {
        local __file_path="$1"
		local __importOp="$2"
		local namespace="$3"
		local basePath=
		local relPath=
		[[ "$__file_path" == *"=="* ]] && {
			# isRelative=true
			basePath="${__file_path/%==*/}"
			relPath="${__file_path/#*==/}"
		}
		local fullPath="${basePath}/${relPath}"
        local __find='/'
        local __rep=':-:'
        local __wrap_function="${namespace}.resource.${relPath//$__find/$__rep}"

		local getFunction="function ${namespace}.resource.get() {${nl}"
		# getFunction="function ${namespace}.resource.get() {\n"
        local nl=$'\n'
		getFunction="${getFunction}    local __file_path=\"\$1\"${nl}"
		getFunction="${getFunction}    local __wrap_function=\"${namespace}.resource.\${__file_path////:-:}\"${nl}"
        getFunction="${getFunction}    import.functionExists \"\${__wrap_function}\" || {${nl}"
        getFunction="${getFunction}        logger.error --message \"Resource '\${__file_path}' not found.\"${nl}"
        getFunction="${getFunction}        logger.die${nl}"
        getFunction="${getFunction}    }${nl}"
		getFunction="${getFunction}    \$__wrap_function${nl}"
		getFunction="${getFunction}}${nl}"
		source <(echo "${getFunction}")
        resource.includeFile "${fullPath}" "${__wrap_function}"
    }

    resource.get() {
        local __file_path="$1"
        local __find='/'
        local __rep=':-:'
        local __wrap_function="resource.${__file_path//$__find/$__rep}"
        import.functionExists "${__wrap_function}" || {
            logger.error \
                --message "Resource '${__file_path}' not found."
            logger.error \
                --message "The resource function '${__wrap_function}' not found."
            logger.error \
                --message "Make sure the resource path exists and has been included as a resource."
            logger.die
        }
        $__wrap_function
    }

}
