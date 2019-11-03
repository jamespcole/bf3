# Public: Initialise the import module.
#
# Loads and initilaises the functions exposed by the import module.  Unlike
# most modules this also automatically calls its own __init() function in
# order to bootstrap the functions required for importing other modules.
# Because it is used to import other modules it needs to be "sourced" to
# make it available.  After this all other modules should be included using
# this module.  NOTE: this module should have no dependencies on other modules,
# therefore convenience functions from other modules cannot be used.
#
# Examples
#
#   source 'modules/import.sh'
#   import.init
#
# Returns the exit code of the last command which would most likely always be 0
# as it is simply loading the module functions in to the global scope
import.init() {
	import.__init() {
		declare -a -g __import_DEPENDENCIES
		declare -A -g __import_LOADED
		declare -A -g __import_INITED
		local -a __import_tmp_paths
		declare -a -g __import_PATHS
		declare -A -g __import_FUNC_SOURCE

		import.loadAppPaths
		import.require 'string'
		import.useModule 'string'
		import.require 'vendor'
		import.useModule 'vendor'
		import.require 'resource'
		import.useModule 'resource'
		import.require 'build.transpiler'
		import.useModule 'build.transpiler'
	}
	import.require() {
		local moduleImportStr="$1"
		local importOp=${2:-file}
		local originalNamespace="${1}"

		local namesSpaceAs="${1}"
		# if it contains == it is a relative import in the format:
		# <Full_path_of_importer>==<namespace>
		[[ "$originalNamespace" == *"=="* ]] && {
			originalNamespace="${originalNamespace/#*==/}"
		}

		# If it start with a dot it's relative, but we should strip it off the
		# namesspace so functions don't start with a .
		[ "${originalNamespace:0:1}" == "." ] && {
			originalNamespace="${originalNamespace/#./}"
		}

		namesSpaceAs="${originalNamespace}"

		local nameSpaceOuter
		local __require_file='module'
		[ "${importOp}" == 'file' ] && {
			__require_file="$3"
		}
		[ "${importOp}" == 'as' ] && {
			namesSpaceAs="$3"
		}
		nameSpaceOuter="${namesSpaceAs}"

		[ "${importOp}" == 'mixin' ] && {
			namesSpaceAs="$3"
			nameSpaceOuter="${namesSpaceAs}.mixin.${originalNamespace}"
		}

		[ "${importOp}" == 'extend' ] && {
			namesSpaceAs="$3"
			nameSpaceOuter="${namesSpaceAs}.extend.${originalNamespace}"
		}

		if [[ ${__import_LOADED["${nameSpaceOuter}"]+exists} ]]; then
			return
		fi

		local moduleFile
		import.getModulePath moduleFile "$moduleImportStr" "$(dirname $(readlink -f ${BASH_SOURCE[1]}))" "$__require_file"

		# Check for new namespace syntax
		local nsLine=$(grep -n "^@namespace" "${moduleFile}")
		local lineNum="${nsLine%%:*}"
		[ "${lineNum}" == '' ] && {
			source "${moduleFile}"
		}

		[ "${lineNum}" != '' ] && {
			local fileDir=$(dirname $(readlink -f "${moduleFile}"))
			local topSourceCode
			topSourceCode=$( import.transpilePreNamespace \
				"${moduleFile}" \
				"${fileDir}" \
				"${lineNum}" \
				"${namesSpaceAs}" \
				"${originalNamespace}" \
				"${importOp}")

			local namespacedCode=$(build.transpiler.transpile "${moduleFile}" "${originalNamespace}" "${importOp}" "${namesSpaceAs}")

			local finalCode=$(echo -e "#!/usr/bin/env bash\n\n# Original Source at:\n# \"${moduleFile}\"\n\n${topSourceCode}\n\n${namespacedCode}")
			# finalCode=$(echo "$finalCode" | sed "s/@super\./echo \"nSpaceAlias = ${namesSpaceAs}, originalNamespace = ${originalNamespace}, operation = ${importOp} \";${originalNamespace}./g")
			# Lame writing to disk for debugging after tranpilation
			echo "${finalCode}" > "/tmp/${nameSpaceOuter}.sh"
			source "/tmp/${nameSpaceOuter}.sh"
			# Much better but harder to debug in-memory sourcing
			# source <(echo "${finalCode}")
		}

		# __import_LOADED["${__im_req_mod_name}"]='1'
		# Change this later so wrapper functions are created that point to the original
		__import_DEPENDENCIES+=("${nameSpaceOuter}")
		__import_LOADED["${nameSpaceOuter}"]='1'
	}

	import.transpilePreNamespace() {
		local moduleFile="$1"
		local fileDir="$2"
		local lineNum="$3"
		local namesSpaceAs="$4"
		local originalNamespace="$5"
		local importOp="$6"

		# This is left commented out as it will be needed to fix the "super"
		# call infinite loop issue.
		# if [ "${importOp}" == 'extend' ]; then
		# 	namesSpaceAs="${namesSpaceAs}._super.${originalNamespace}"
		# 	# echo "${namesSpaceAs}"
		# fi
		local baseNamespace="${namesSpaceAs%%._super*}"
		# We want it to keep the base namespace when aliasing
		# if [ "${importOp}" == 'as' ]; then
		# 	 # && [[ "$nSpaceAlias" == *"_super"* ]]
		# 	namesSpaceAs="${namesSpaceAs%%._super*}"
		# fi

		# Extract the code before the namespace declaration
		local topSourceCode=$(head -n+$((lineNum - 1)) "${moduleFile}")
		# Replace the @rel==namespace referfences, eg: import.require '@rel==functions'
		topSourceCode=$(echo "${topSourceCode}" | sed "s&@rel==&${fileDir}==&")
		# Replace the @this. references, eg: import.require 'examples.ex1' as '@this.t2'
		topSourceCode=$(echo "${topSourceCode}" | sed "s& as '@this\.& as '${baseNamespace}.&")
		topSourceCode=$(echo "${topSourceCode}" | sed "s& as '@this& as '${baseNamespace}&")

		topSourceCode=$(echo "${topSourceCode}" | sed "s& mixin '@this\.& mixin '${namesSpaceAs}.&")
		topSourceCode=$(echo "${topSourceCode}" | sed "s& mixin '@this& mixin '${namesSpaceAs}&")

		topSourceCode=$(echo "${topSourceCode}" | sed "s& extend '@this\.& extend '${namesSpaceAs}._super.${originalNamespace}.&")
		topSourceCode=$(echo "${topSourceCode}" | sed "s& extend '@this& extend '${namesSpaceAs}._super.${originalNamespace}&")

		topSourceCode=$(echo "${topSourceCode}" | sed "s&@this\.&${baseNamespace}.&")
		# Replace any references at the end of a string
		topSourceCode=$(echo "${topSourceCode}" | sed "s&@this&${baseNamespace}&")

		echo "${topSourceCode}"
	}

	import.getModulePath() {
		local __returnvar=$1
		local importNs="$2"
		local passedNs="$2"
		local nsStr="$2"
		local importerFilePath="${3}"
		local requireFile="${4:-module}"

		local oldRelativePath=''
		[ "${importNs:0:1}" == "." ] && {
			importNs=${importNs/#./}
			oldRelativePath="$(dirname $(readlink -f "${BASH_SOURCE[2]}"))"
		}
		[[ "$importNs" == *"=="* ]] && {
			importNs="${importNs/#*==/}"
		}

		# For old syntax
		if [[ "$importNs" == *">"* ]]; then
		  # Everything after the ">" is appended to the file for backwards
		  # compatibility for bf2 style "module>base" syntax
		  requireFile="${requireFile}.${importNs##*>}"
		fi

		# Temporarily replace "../" with "<</"
		local pathPiece="${nsStr//..\//<</}"

		# Should be deprecated to use @rel== instead of leading '.'
		# If it starts with a '.' it's relative bu
		[ "${pathPiece:0:1}" == "." ] && {
			pathPiece="${pathPiece:1}"
		}
		# echo "${pathPiece}"
		# Support old style imports
		pathPiece=${pathPiece%%>*}
		# Split the transpiled absolute path(eg. @rel== syntax)
		pathPiece="${pathPiece/==//}"
		# Replace "." with "/"
		pathPiece="${pathPiece//.//}"
		# Swap the "<</" back to "../"
		pathPiece="${pathPiece//<<\//../}"
		# Trim trailing slash
		[[ "${pathPiece: -1}" == '/' ]] && {
			pathPiece="${pathPiece:0:-1}"
		}

		if [ "${oldRelativePath}" != '' ]; then
			pathPiece="${oldRelativePath}/${pathPiece}"
		fi
		local modFilePath=

		# No leading "/" so assume it's a relative
		[[ "${pathPiece:0:1}" == "/" ]] || {
			for checkPath in "${__import_PATHS[@]}"; do
				local fPath="${checkPath}/modules/${pathPiece}/${requireFile}.sh"
				[ -f "${fPath}" ] && {
					modFilePath="${fPath}"
					break;
				}
				# Fall back to looking for a file with the same name as the
				# namespace if the default "module.sh" isn't found
				fPath="${checkPath}/modules/${pathPiece}/${importNs}.sh"
				[ -f "${fPath}" ] && {
					modFilePath="${fPath}"
					break;
				}
			done
		}


		# It's an absolute path
		[[ "${pathPiece:0:1}" == "/" ]] && {
			# Resolve relative pathing and get the directory name as namespace
			importNs="$(basename $(readlink -f "${pathPiece}"))"
			# Order is important: we favour the requirefile, so check that last.
			local absPath="${pathPiece}/${importNs}.sh"
			[ -f "${absPath}" ] && {
				modFilePath="${absPath}"
			}
			absPath="${pathPiece}/${requireFile}.sh"
			[ -f "${absPath}" ] && {
				modFilePath="${absPath}"
			}

			absPath="${pathPiece}.sh"
			[ -f "${absPath}" ] && {
				modFilePath="${absPath}"
			}
		}

		[ -f "${modFilePath}" ] || {
			import.die "Could not load namespace '${importNs}' file not found at '${modFilePath}'"
		}

		if [[ "$__returnvar" ]]; then
			eval $__returnvar="$(echo -e '$modFilePath')"
		else
			echo "$modFilePath"
		fi
	}

	import.initModule() {
		local __import_modName="$1"
		if ! import.functionExists "${__import_modName}.init"; then
			echo "ERROR: Could not find module '${__import_modName}' init function."
			import.die
		fi
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
		# for __module in "${!__import_LOADED[@]}"
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
	import.loadAppPaths() {
		local -a __import_tmp_paths
		local __ifs_tmp="$IFS"
		IFS=':' read -r -a __import_tmp_paths <<< "$BF3_PATH"
		IFS="$__ifs_tmp"
		local __import_script_path="$(dirname $(readlink -f "${BASH_SOURCE}"))"
		__import_script_path="$(readlink -f "${__import_script_path}/..")"
		local __import_path_var
		local -a __import_tmp_paths_clean
		local __import_include_current_path=1
		for __import_path_var in "${__import_tmp_paths[@]}"
		do
			if [ "$__import_path_var" != '' ]; then
				__import_tmp_paths_clean+=("$__import_path_var")
			fi
			if [ "$__import_path_var" == "$__import_script_path" ]; then
				__import_include_current_path=0
			fi
		done

		if [ $__import_include_current_path -eq 1 ]; then
			__import_tmp_paths_clean+=("$__import_script_path")
		fi

		local __import_path_count=${#__import_tmp_paths_clean[@]}
		let __import_path_count=__import_path_count=0

		for __import_path_var in "${__import_tmp_paths_clean[@]}"
		do
			__import_PATHS["${__import_path_count}"]="$__import_path_var"
			let __import_path_count=__import_path_count+1
		done
	}

	import.extension() {
		local __extension="$1"
		local __caller_path="$(dirname $(readlink -f "${BASH_SOURCE[1]}"))"
		local __filename="${__extension##*.}.sh"
		local __extension_path="${__caller_path}/extensions/${__filename}"
		source "$__extension_path"
	}

	import.useExtension() {
		local __extension_namespace="$1"
		"${__extension_namespace}.init"
		if import.functionExists "${__extension_namespace}.__init"; then
			"${__extension_namespace}.__init"
		fi

	}

	import.stackTrace() {
		echo "$1"
		echo "-------------- Stack Trace -----------------"
		local frame=0
		while caller $frame; do
			((frame++));
		done
		echo "$*"
	}

	import.die() {
		import.stackTrace "$@"
		exit 1
	}
	# This is here because the init module is only loaded once
	# normally modules should not do this
	# import.__init
	return $?
}
