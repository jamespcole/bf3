import.require 'string'

build.transpiler.init() {

    build.transpiler.transpile() {
        local sourceFile="$1"
        local originalNamespace="$2"
        local operation="${3}"
        local nSpaceAlias="$4"






        local nSpace="${originalNamespace}"

        [ "${operation}" == 'as' ] && {
            nSpace="$nSpaceAlias"
        }

        [ "${operation}" == 'mixin' ] && {
            nSpace="$nSpaceAlias"
        }

        [ "${operation}" == 'extend' ] && {
            nSpace="$nSpaceAlias"
        }

        build.transpiler.logToErr "importing ${originalNamespace} ${operation} ${nSpace}"


        local baseNamespace="${nSpace%%._super*}"

        local nsLine=$(grep -n "^@namespace" "${sourceFile}")
        local lineNum="${nsLine%%:*}"
        # local varsArrName="BF3_${nSpace//./_}_VARS"
        local varsArrName="BF3_${baseNamespace//./_}_VARS"

        local nSpaceOuter=$(build.transpiler.getOuterNamespace "${originalNamespace}" "${operation}" "${nSpace}" )
        build.transpiler.logToErr "${nSpaceOuter}"

        local superNspace=$(build.transpiler.getSuperNamespace "${originalNamespace}" "${operation}" "${nSpace}" )
        build.transpiler.logToErr "${superNsapce}"

        local funcEnd="()"
        local sourceCode=$(tail -n+"${lineNum}" "${sourceFile}")
        local wrapped=$(echo "${sourceCode}" | sed "s/@namespace//")

        local varsArrCode="if [ -z  \$${varsArrName}_REAL ]; then\n"
        varsArrCode="${varsArrCode}declare -A -g ${varsArrName}_REAL\n"
        varsArrCode="${varsArrCode}declare -g -n ${varsArrName}=${varsArrName}_REAL\n"
        varsArrCode="${varsArrCode}fi\n\n"
        varsArrCode="${varsArrCode}@this[namespace]='$baseNamespace'\n\n"
        wrapped="${varsArrCode}\n${wrapped}\n"
        wrapped="${nSpaceOuter}.init${funcEnd} {\n${wrapped}\n}"

        transpile_realGet() {
            local source="$1"

            echo -e "$source" \
                | perl -pe 's%(\@get=>.*?\[)% ($_x = $1) =~ s/\./_/g; $_x %eg' \
                | sed "s/@get=>\([^[]*\)\[\([^]]*\)\]/\${BF3_\1_VARS_REAL['\2']}/g"
        }
        transpile_realSet() {
            local source="$1"

            echo -e "$source" \
                | perl -pe 's%(\@set=>.*?\[)% ($_x = $1) =~ s/\./_/g; $_x %eg' \
                | sed "s/@set=>\([^[]*\)\[\([^]]*\)\]=/BF3_\1_VARS_REAL['\2']=/g"

        }
        transpile_arrGet() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@get\(.*?[\)|\]])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@get(\([^)]*\))/\${BF3_\1}/g"
        }

        transpile_assocKeys() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@keys\(.*?[\)|\]])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@keys(\([^)]*\))/\${!BF3_\1[@]}/g"
        }

        transpile_arrCreate() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@create\[\]\(.*?[\)|\]])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@create\[\](\([^)]*\))/\[ -z \$BF3_\1 ] \&\& declare -a -g BF3_\1/g"
        }

        transpile_assocCreate() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@create\{\}\(.*?[\)|\]])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@create{}(\([^)]*\))/\[ -z \$BF3_\1 ] \&\& declare -A -g BF3_\1/g"
        }

        transpile_arrSet() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@set\(.*?[\)|\]])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@set(\([^)]*\))=/\BF3_\1=/g"
        }

        transpile_arrAdd() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@add\(.*?[\)])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@add(\([^)]*\))+=/\BF3_\1+=/g"
        }

        # eg. @arrStr(test.tes1.hhh)
        # would be replaced with:
        # declare -p BF3_test_tes1_hhh
        transpile_arrToStr() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@arrStr\(.*?[\)])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@arrStr(\([^)]*\))/\declare -p BF3_\1/g"
        }

        # eg. @expand(something.someArray)
        # would be replaced with:
        # ${BF3_something_someArray[@]}
        transpile_arrExpand() {
            local source="$1"

            echo -e "$source" \
            | perl -pe 's%(\@expand\(.*?[\)])% ($_x = $1) =~ s/\./_/g; $_x %eg;' \
            | sed "s/@expand(\([^)]*\))/\${BF3_\1[@]}/g"
        }

        transpile_varRef() {
            local source="$1"
            # eg: when doing this:
            # @ref(@this[host]->['name'])
            # and in this case @this[host] is a variable containing a namespace name
            # it will use variable indirection to dynaimcally build and retrieve the
            # correct namespace variable.
            #
            # 1. The transpilation changes:
            # @ref(@this[host]->['name'])
            # to:
            # @ref(\${BF3_coreService1_VARS[host]}->['name'])
            # 2. The @ref transpilation changes it to
            # $(local __ref="BF3_${BF3_coreService1_VARS[host]}_VARS['name']"; echo "${!__ref}"; unset __ref;)
            #
            echo -e "$source" \
                | sed "s/@ref(\([^)]*\)->\([^)]*\))/\$(local __ref=\"BF3_\1_VARS\2\"; echo \"\${!__ref}\"; unset __ref;)/g"
        }

        # transpile_originalNamespacepropRef() {
        #     local source="$1"
        #
        #     echo -e "$source" \
        #         | sed "s/@refProp(\([^)]*\)->\([^)]*\))/\$(local __ref=\"BF3_\1\2\"; echo \"\${!__ref}\"; unset __ref;)/g"
        # }

        transpile_globals() {
            local source="$1"
            echo -e "$source" \
                | sed "s/@globals\[\([^]]*\)\]/\${globals['\1']}/g"
        }

        # Replace references to @this.
        # Replace references to @this:
        # Replace assignments to params, eg: @params[my_param_key]="somevale"
        # Replace access to params, eg: echo "@params[my_param_key]"
        # Replace @=>params with parameter loading code
        # Replace assignments to namespace vars, eg: @this[my_param_key]="somevale"
        # Replace access to namespace vars, eg: echo "@this[my_param_key]"

        # | sed "s/@=>params/\"\${FUNCNAME[0]}::args\"; local -A params; parameters.load --namespace \"${baseNamespace}.\${FUNCNAME[0]##*.}\" --args \"\$@\"\n/" \

        local transpiled
        transpiled=$(echo -e "${wrapped}" \
            | sed "s/@this\.super\./${superNspace}._super./g" \
            | sed "s/@this\./${baseNamespace}./g" \
            | sed "s/@this:/${baseNamespace}:/g" \
            | sed "s/@params\[\([^]]*\)\]=/params['\1']=/g" \
            | sed "s/@params\[\([^]]*\)\]/\${params['\1']}/g" \
            | sed "s/@=>\*params/\"${baseNamespace}.\${FUNCNAME[0]##*.}::args\"; local -A params; local -a unknown; parameters.load --namespace \"${baseNamespace}.\${FUNCNAME[0]##*.}\" --ignore-unknown true --skip-validation \"\${skipValidation:=false}\" --ignore-errors \"\${ignoreErrors:=false}\" --args \"\$@\"\n/" \
            | sed "s/@=>params/\"${baseNamespace}.\${FUNCNAME[0]##*.}::args\"; local -A params; parameters.load --namespace \"${baseNamespace}.\${FUNCNAME[0]##*.}\" --skip-validation \"\${skipValidation:=false}\" --ignore-errors \"\${ignoreErrors:=false}\" --args \"\$@\"\n/" \
            | sed "s/@this\[\([^]]*\)\]=/${varsArrName}[\1]=/g" \
            | sed "s/@this\[\([^]]*\)\]/\${${varsArrName}[\1]}/g" \
            | sed "s/@this=>\[\([^]]*\)\]=/${varsArrName}_REAL['\1']=/g" \
            | sed "s/@this=>\[\([^]]*\)\]/\${${varsArrName}_REAL['\1']}/g" \
            | sed "s/@prop\[\([^]]*\)\]/\${${varsArrName}['\1']}/g" \
            | perl -pe 's%(\@get->.*?\[)% ($_x = $1) =~ s/\./_/g; $_x %eg' \
            | sed "s/@get->\([^[]*\)\[\([^]]*\)\]/\${BF3_\1_VARS['\2']}/g" \
            | perl -pe 's%(\@set->.*?\[)% ($_x = $1) =~ s/\./_/g; $_x %eg' \
            | sed "s/@set->\([^[]*\)\[\([^]]*\)\]=/BF3_\1_VARS['\2']=/g")

        transpiled=$(transpile_globals "${transpiled}")
        transpiled=$(transpile_realGet "${transpiled}")
        transpiled=$(transpile_realSet "${transpiled}")
        transpiled=$(transpile_arrCreate "${transpiled}")
        transpiled=$(transpile_arrGet "${transpiled}")
        transpiled=$(transpile_arrSet "${transpiled}")
        transpiled=$(transpile_arrToStr "${transpiled}")
        transpiled=$(transpile_assocCreate "${transpiled}")
        transpiled=$(transpile_assocKeys "${transpiled}")
        transpiled=$(transpile_varRef "${transpiled}")
        transpiled=$(transpile_arrAdd "${transpiled}")
        transpiled=$(transpile_arrExpand "${transpiled}")

        unset transpile_globals
        unset transpile_realSet
        unset transpile_realGet
        unset transpile_arrCreate
        unset transpile_arrGet
        unset transpile_arrSet
        unset transpile_arrToStr
        unset transpile_assocCreate
        unset transpile_assocKeys
        unset transpile_varRef
        unset transpile_arrAdd
        unset transpile_arrExpand

        # echo "@call(@this[host].functionCall) more [ test ] ( items )" | sed "s/@this\[\([^]]*\)\]/\${BF3_node1_VARS['\1']}/g" | sed "s/@call(\([^)]*\))/\"\1\"/g"
        # echo "\"@this[host]\".functionCall more [ test ] ( items )" | sed "s/@this\[\([^]]*\)\]/\${BF3_node1_VARS['\1']}/g" | sed "s/@call(\([^)]*\))/\"\1\"/g"

        local outputPath=$(mktemp)
        echo "$transpiled" > "${outputPath}"
        # echo "$transpiled"

        # Try and source into a fresh subshell first and check for error.
        # NOTE: this is madly innefficient but it is only used during
        # development, the dist version is built into a sigle file and does
        # not nead to transpile every include.
        local syntaxCheck=$(bash -c 'source  '""${outputPath}""' 2>&1')
            # && source <(namespace '""${moduleFile}""' ""'${namesSpaceAs}'"" ""'${nameSpaceOuter}'"" ""'${importOp}'"" ""'${originalNamespace}'"") 2>&1')"
        if [ "${syntaxCheck}" != '' ]; then
            echo "SYNTAX ERROR:"
            echo "${syntaxCheck}"
            echo "------------- Transpiler Output -------------"
            cat "${outputPath}" \
                | awk '{ print NR": "$0}'
            import.stackTrace

            echo "---------------------"
            echo "Original source at: ${sourceFile}"
            return 1
        fi

        local formattedCode=$(bash -c 'source  '""${outputPath}""' && declare -f')
        # echo "${formattedCode}"

        local functionNames=$(bash -c 'source  '""${outputPath}""' && '""${nSpaceOuter}'"".init && declare -F' | awk -F'-f ' '{ print $2 }' )
        # echo "${functionNames}"


        local baseNamespace="${nSpaceAlias%%._super*}"

        local nl=$'\n'
        local extraFunctions
        local functionName
        while read functionName; do
            if [ "${operation}" == 'extend' ] && [ "${functionName}" != "${nSpaceOuter}.init" ] && [[ $functionName != __global::* ]]; then

                # One explict function for supporting multiple inheritance if required
                local superCall="${nSpace}._super.${originalNamespace}.${functionName}"
                extraFunctions="${extraFunctions}\n    ${nSpace}.${functionName}(){"
                extraFunctions="${extraFunctions}\n        ${nSpace}._super.${functionName} \"\$@\""
                extraFunctions="${extraFunctions}\n    }\n"
                __import_FUNC_SOURCE["${superCall}"]="${sourceFile}"
                # One generic function for ease of use, eg: @this.super.myFunc
                # in the case of multiple inheritance the extension added last
                # will be the target pf the proxy function
                extraFunctions="${extraFunctions}\n    ${nSpace}._super.${functionName}(){"
                extraFunctions="${extraFunctions}\n        ${superCall} \"\$@\""
                extraFunctions="${extraFunctions}\n    }\n"


                extraFunctions="${extraFunctions}\n    ${baseNamespace}._super.${functionName}(){"
                extraFunctions="${extraFunctions}\n        ${superCall} \"\$@\""
                extraFunctions="${extraFunctions}\n    }\n"

                extraFunctions="${extraFunctions}\n    ${baseNamespace}.${functionName}(){"
                extraFunctions="${extraFunctions}\n        ${superCall} \"\$@\""
                extraFunctions="${extraFunctions}\n    }\n"

                __import_FUNC_SOURCE["${nSpace}.super.${functionName}"]="${sourceFile}"
            fi


            # This is for functions suffixed with "::precache", these will be called
            # during the build to cache long running results like docs generation so
            # that they do not be created on the fly each time.
            if string.endsWith '::precache' "$functionName"; then
                local realName
                # TODO: this really needs to be refactored
                string.removeSuffix realName "::precache" "$functionName"
                extraFunctions="${extraFunctions}\n    ${nSpace}.${realName}(){"
                extraFunctions="${extraFunctions}\n        if import.functionExists \"\${FUNCNAME[0]}::cached\"; then\n"
                extraFunctions="${extraFunctions}\n            \"\${FUNCNAME[0]}::cached\"\n"
                extraFunctions="${extraFunctions}\n            return\n"
                extraFunctions="${extraFunctions}\n        fi\n"
                extraFunctions="${extraFunctions}\n        local result=\$(\"\${FUNCNAME[0]}::precache\" \"\$@\")"
                extraFunctions="${extraFunctions}\n        local __wrapped_function=\"\${FUNCNAME[0]}::cached() { "
                extraFunctions="${extraFunctions}        cat << 'EOF'\n\${result}${nl}EOF${nl}"
                extraFunctions="${extraFunctions}            }\""
                extraFunctions="${extraFunctions}\n        eval \"\${__wrapped_function}\";"
                extraFunctions="${extraFunctions}\n        \${FUNCNAME[0]}::cached"
                extraFunctions="${extraFunctions}\n    }\n"
            fi

            __import_FUNC_SOURCE["${nSpace}.${functionName}"]="${sourceFile}"
        done < <(echo "${functionNames}")


        # Prepend the namespace to all functions
        local nsPrefix="${baseNamespace}"
        if [ "${operation}" == 'extend' ]; then
            nsPrefix="${nSpace}._super.${originalNamespace}"
        fi
        local namespacedCode="${formattedCode}"
        # If a funtion name is prefixed with "__global::" it is not prefixed with the namespace
        namespacedCode=$(echo "${namespacedCode}" | sed "s/\(function __global::\)\(.*\) ()/\2()/")
        namespacedCode=$(echo "${namespacedCode}" | sed "s/\(function \)\(.*\) ()/${nsPrefix}.\2()/")

        # if [ "${operation}" == 'extend' ]; then
            extraFunctions=$(echo -e "${extraFunctions}")
            # remove the last brace so we can append our super proxy functions
            namespacedCode=$(echo "${namespacedCode}" | head -n-1)

            namespacedCode="${namespacedCode}${nl}${extraFunctions}${nl}}"
        # fi

        echo "${namespacedCode}"

        # local functionNames=$(bash -c 'source  '""${outputPath}""' && declare -f') $(bash -c 'source  '""${outputPath}""' && declare -f')
        #     && source <(namespace '""${moduleFile}""' ""'${namesSpaceAs}'"" ""'${nameSpaceOuter}'"" ""'${importOp}'"" ""'${originalNamespace}'"") \
        #     && unset namespace \
        #     && '""${nameSpaceOuter}".init"' \
        #     && declare -F ')" | awk -F'-f ' '{ print $2 }')

    }

    build.transpiler.logToErr() {
        # (>&2 echo "${1}")
        local disabled
    }

    build.transpiler.getOuterNamespace(){
        local originalNamespace="$1"
        local importOp="$2"
        local targetNs="$3"
        local nameSpaceOuter="${targetNs}"
        local namespaceAs="${originalNamespace}"

        [ "${importOp}" == 'mixin' ] && {
            namesSpaceAs="$targetNs"
            nameSpaceOuter="${namesSpaceAs}.mixin.${originalNamespace}"
        }

        [ "${importOp}" == 'extend' ] && {
            namesSpaceAs="$targetNs"
            nameSpaceOuter="${namesSpaceAs}.extend.${originalNamespace}"
        }
        echo "${nameSpaceOuter}"
    }

    build.transpiler.getSuperNamespace(){
        local originalNamespace="$1"
        local importOp="$2"
        local targetNs="$3"
        local nameSpaceOuter="${targetNs}"
        local namespaceAs="${originalNamespace}"

        [ "${importOp}" == 'extend' ] && {
            namesSpaceAs="$targetNs"
            nameSpaceOuter="${namesSpaceAs}._super.${originalNamespace}"
        }
        echo "${nameSpaceOuter}"
    }
}
