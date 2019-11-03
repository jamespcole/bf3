#!/usr/bin/env bash

bf3.bootstrap.addToPath() {
	local pathStr=":$1:"
	local addPath="$2"
	# local thisPath="$(dirname $(readlink -f ${BASH_SOURCE}))"

	pathStr=${pathStr/:$removePath:/:}
    # WORK => :/bin:/sbin:

	[[ $pathStr == *":${addPath}:"* ]] || {
		pathStr=":${addPath}${pathStr}"
	}

	pathStr=${pathStr%:}
    pathStr=${pathStr#:}
	echo "${pathStr}"
}


bf3.bootstrap.removePath() {
    # PATH => /bin:/opt/a dir/bin:/sbin
    local pathStr=":$1:"
    local removePath="$2"

    # WORK => :/bin:/opt/a dir/bin:/sbin:
    pathStr=${pathStr/:$removePath:/:}
    # WORK => :/bin:/sbin:
    pathStr=${pathStr%:}
    pathStr=${pathStr#:}
    # export PATH="$pathStr"
    echo "$pathStr"
}

bf3.bootstrap.removePaths() {
    local __app_paths
    local IFS=':'
    read -r -a __app_paths <<< "${BF3_PATH}"
    local __app_path
    local __newPath="$PATH"
    for __app_path in "${__app_paths[@]}"
    do
        if [ "$__app_path" != '' ]; then
            __newPath=$(bf3.bootstrap.removePath "$__newPath" "${__app_path}/install_hooks")
        fi
    done
    echo "${__newPath}"
}

bf3.bootstrap.printSummary() {
	echo "BF3 Environment Activated"
	echo "Active Environment Path: '${BF3_ACTIVE_PATH}'"
	echo "Active Environment Bootstrap: '${BF3_BOOTSTRAP}'"
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
