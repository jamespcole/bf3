@namespace

@this=>[targetNamespace]=''

setTarget() {
    @this=>[targetNamespace]="${1}"
    local targetNamespace="@this=>[targetNamespace]"

    local functionList=$(declare -F \
        | grep "${targetNamespace}" \
        | grep -v '.init$' \
        | grep -v '.__init$' \
        | awk -F' -f ' '{ print $2 }' \
        | sed "s/${targetNamespace}\.//")

    local namespace="${FUNCNAME[0]/.setTarget/}"
    local functions
    local functionBaseName
    while read functionBaseName; do
        functions="${functions}${namespace}.${functionBaseName}(){\n"
        functions="${functions}    ${targetNamespace}.${functionBaseName} \"\$@\"\n"
        functions="${functions}}\n\n"
    done < <(echo "${functionList}")

    local targetVars="BF3_${targetNamespace//./_}_VARS"
    # unset "BF3_${namespace//./_}_VARS"
    declare -g -n "BF3_${namespace//./_}_VARS"="${targetVars}"


    source <(echo "$functions")
}

# getVar() {
#     echo "${}"
# }
