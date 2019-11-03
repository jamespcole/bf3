import.init() {
	import.__init() {
        declare -A -g __import_LOADED
		declare -A -g __import_INITED
		local -a __import_tmp_paths
		declare -a -g __import_PATHS
		# import.useModule 'vendor'
        return 0
	}
	import.require() {
		return 0
	}
	import.getModulePath() {
		return 0
	}
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
    import.functionExists() {
	    declare -f -F $1 > /dev/null
	    return $?
	}
	import.loadAppPaths() {
		return 0
	}
	# This is here because the init module is only loaded once
	# normally modules should not do this
	import.__init
	return 0
}
