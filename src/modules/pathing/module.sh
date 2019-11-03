import.require 'string'
# import.require 'params'

@namespace

closestParentFile::args() {
    parameters.add --key 'filename' \
        --namespace '@this.closestParentFile' \
        --name 'Filename' \
        --alias '--filename' \
        --desc 'The filename to search for.' \
        --required '1' \
        --has-value 'y'

    parameters.add --key 'return' \
        --namespace '@this.closestParentFile' \
        --name 'Return Var' \
        --alias '--return' \
        --desc 'The variable which will be assigned to return result.' \
        --required '1' \
        --has-value 'y'

    parameters.add --key 'from' \
        --namespace '@this.closestParentFile' \
        --name 'From Path' \
        --alias '--from' \
        --desc 'The path to begin the search from, defaults to the path of the caller.' \
        --required '0' \
        --default "$(dirname $(readlink -f "${BASH_SOURCE[1]}"))" \
        --has-value 'y'
}

closestParentFile() {
#     local -A __params
#     __params['filename']='' # Filename to search for
#     __params['return']='' # The return variable from the caller
#     # The path to begin the search from, defaults to the path of the caller
#     __params['from']="$(dirname $(readlink -f "${BASH_SOURCE[1]}"))"
#     params.get "$@"
    @=>params

    local pathingCurDir="@params[from]"
    echo "filename is @params[filename] from @params[from]"
    while [[ "$pathingCurDir" != / ]] ; do
        local pathingSearchRes=$(find "$pathingCurDir"/ \
            -maxdepth 1 \
            -name "@params[filename]")
        if [ ! "$pathingSearchRes" == "" ]; then
            string.return_value "$pathingCurDir" @params[return]
            return 0
        fi
        pathingCurDir=$(readlink -f "${pathingCurDir}/..")
    done
    return 1
}
