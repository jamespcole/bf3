string.init() {
    # USAGE: string.return_value  "my cool string" $__return_val
    string.return_value() {
        local __value="$1"
        local __returnvar=$2
        if [[ "$__returnvar" ]]; then
            eval $__returnvar="$(echo -e '$__value')"
        else
            echo "$__value"
        fi
    }
    string.padding() {
        local __return=$1
        local __pad_chars="$2"
        local __length="$3"

        if [ "$__pad_chars" == ' ' ]; then
            __pad_chars="@:space:@"
        fi
        local __pad_str=$(echo -e "$__pad_chars" \
            | awk -v r="$__length" '{ for(i=0;i<r;i++) printf $1; } END { printf "\n" }')
        __pad_str="${__pad_str//@:space:@/ }"
        string.return_value "$__pad_str" $__return
    }
    string.pad() {
        local __return=$1
        local __in_str="$2"
        local __pad_chars="$3"
        local __length="$4"
        local __in_len=${#__in_str}
        local __to_pad
        let __to_pad=__length-__in_len
        if [ "$__to_pad" -gt 0 ]; then
            if [ "$__pad_chars" == ' ' ]; then
                __pad_chars="@:space:@"
            fi
            local __pad_str=$(echo -e "$__pad_chars" \
                | awk -v r="$__to_pad" '{ for(i=0;i<r;i++) printf $1; } END { printf "\n" }')
            __pad_str="${__pad_str//@:space:@/ }"
        fi
        string.return_value "${__in_str}${__pad_str}" $__return
    }
    string.endsWith() {
        local __needle="$1"
        local __haystack="$2"

        local __needle_len="${#__needle}"
        local __start=$(( ${#__haystack} - ${__needle_len} ))
        if [ $__start -lt 0 ]; then
            return 1
        fi

        if [ "${__haystack:$__start:$__needle_len}" == "$__needle" ]; then
            return 0
        else
            return 1
        fi
    }
    string.startsWith() {
        local __needle="$1"
        local __haystack="$2"

        local __needle_len="${#__needle}"
        local __start=0
        if [ $__start -lt 0 ]; then
            return 1
        fi

        if [ "${__haystack:$__start:$__needle_len}" == "$__needle" ]; then
            return 0
        else
            return 1
        fi
    }
    string.removePrefix() {
        local __returnvar=$1
        local __needle="$2"
        local __haystack="$3"

        local __needle_len="${#__needle}"
        local __start=0
        if ! string.startsWith "$__needle" "$__haystack"; then

            if [[ "$__returnvar" ]]; then
                eval $__returnvar="$(echo -e '$__haystack')"
            else
                echo "$return_var"
            fi
            return 1
        else
            local __new_val=${__haystack/#$__needle/}

            if [[ "$__returnvar" ]]; then
                eval $__returnvar="$(echo -e '$__new_val')"
            else
                echo "$return_var"
            fi
            return 0
        fi

    }
    string.removeSuffix() {
        local __returnvar="$1"
        local __needle="$2"
        local __haystack="$3"

        local __needle_len="${#__needle}"
        local __start=0
        if ! string.endsWith "$__needle" "$__haystack"; then

            if [[ "$__returnvar" ]]; then
                eval $__returnvar="$(echo -e '$__haystack')"
            else
                echo "$return_var"
            fi
            return 1
        else
            local __new_val=${__haystack/%$__needle/}

            if [[ "$__returnvar" ]]; then
                eval $__returnvar="$(echo -e '$__new_val')"
            else
                echo "$return_var"
            fi
            return 0
        fi
    }
    string.countChar() {
        local __return_val=$1
        local __needle="$2"
        local __haystack="$3"
        local __temp_str=${__haystack/${__needle}/}
        local __char_num=$(( ${#__haystack} - ${#__temp_str} ))

        eval $__return_val="$(echo -e '$__char_num')"
    }
    string.toUpper() {
        local __return_val=$1
        local __str="$2"

        local __ret=${__str^^}
        string.return_value "$__ret" $__return_val
    }
    string.toLower() {
        local __return_val=$1
        local __str="$2"

        local __ret=${__str,,}
        string.return_value  "$__ret" $__return_val
    }
    string.contains() {
        local __needle="$1"
        local __haystack="$2"

        if [[ "$__haystack" == *"$__needle"* ]]; then
            return 0
        else
            return 1
        fi
    }
    string.replace() {
        local __return_val=$1
        local __needle="$2"
        local __replace="$3"
        local __haystack="$4"

        local __ret=${__haystack/$__needle/$__replace}
        string.return_value "$__ret" $__return_val
    }

    string.trimLeft() {
        local __return_val=$1
        local var="$2"
        # remove leading whitespace characters
        var="${var#"${var%%[![:space:]]*}"}"

        string.return_value "$var" $__return_val
    }

    string.trimRight() {
        local __return_val=$1
        local var="$2"
        # remove trailing whitespace characters
        var="${var%"${var##*[![:space:]]}"}"

        string.return_value "$var" $__return_val
    }

    string.trim() {
        local __return_val=$1
        local var="$2"

        local __trimmed
        string.trimLeft __trimmed "$var"
        string.trimRight __trimmed "$__trimmed"

        string.return_value "$__trimmed" $__return_val
    }

    string.hash() {
        cksum <<< "${1}" | cut -f 1 -d ' '
    }

}
