import.require 'chars'
import.require 'mustache'
import.require 'string'
import.require 'provision'
import.require 'provision.figlet'
import.require 'provision.visual.graphviz.graph_easy'

@namespace

@create{}(@this.state)
@set(@this.state['bold'])=0
@set(@this.state['underline'])=0
@set(@this.state['emphasis'])=0
@set(@this.state['remove_nl'])=0
@set(@this.state['nl_to_tab'])=0
@set(@this.state['remove_tab'])=0
@set(@this.state['fg_colour'])=
@set(@this.state['bg_colour'])=

@create{}(@this.cached)

@create{}(@this.settings)
@set(@this.settings['props_changed'])='0'

@this[themeId]='default'
@create{}(@this.theme)

__init() {
    @this.loadTheme
}


loadTheme() {
    @set(@this.cached['bold'])=$(tput bold)
    @set(@this.cached['reset'])=$(tput sgr0)
    @set(@this.cached['dim'])=$(tput dim)
    @set(@this.cached['underline'])=$(tput smul)
    @set(@this.cached['removeUnderline'])=$(tput rmul)
    @set(@this.cached['em'])=$(tput smso)
    @set(@this.cached['removeEm'])=$(tput rmso)

    @set(@this.theme["@this[themeId]>>icon_danger"])="@get(chars.figs['SKULL']) "
    @set(@this.theme["@this[themeId]>>icon_info"])="@get(chars.figs['INFO_ROUND']) "
    @set(@this.theme["@this[themeId]>>icon_warning"])="@get(chars.figs['WARN']) "
    @set(@this.theme["@this[themeId]>>icon_success"])="@get(chars.figs['TICK']) "

    @set(@this.theme["@this[themeId]>>hr-char"])="@get(chars.box['THIN_EW']) "

    @set(@this.theme["@this[themeId]>>red"])='167'
    @set(@this.theme["@this[themeId]>>purple"])='67'
    @set(@this.theme["@this[themeId]>>blue"])='24'
    @set(@this.theme["@this[themeId]>>light-blue"])='109'
    @set(@this.theme["@this[themeId]>>yellow"])='100'
    @set(@this.theme["@this[themeId]>>green"])='47'
    @set(@this.theme["@this[themeId]>>orange"])='173'
    @set(@this.theme["@this[themeId]>>cyan"])='66'
    @set(@this.theme["@this[themeId]>>default"])='121'
    @this.setProp --prop 'fg_colour' --state 'default'
}



indent() {
    echo "$1" | sed 's/^/    &/'
}
list() {
    echo "$1" | sed 's/^./    &/'
}
listItem() {
    echo "$(echo -en @get(chars.figs['SMALL_CIRCLE'])) $1"
}

icon() {
    echo "$(echo -en @get(@this.theme[@this[themeId]>>icon_$1]))"
}


heading1() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'bold' --state 1
    @this.setProp --prop 'fg_colour' --state 'orange'
    local heading="$(figlet -f standard.flf "$1")"
    @this.print --text "$heading"
    @this.restoreState "${__prev_state}"
    @this.printLine --text ""
    # echo ""
    @this.hr
}

heading2() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'bold' --state 1
    @this.setProp --prop 'fg_colour' --state 'orange'
    local heading="$(figlet -f small.flf "$1")"
    @this.print --text "$heading"
    @this.restoreState "${__prev_state}"
    # @this.printLine --text ""
}

heading3() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'orange'
    local heading="$(figlet -f mini.flf "$1")"
    @this.print --text "$heading"
    @this.restoreState "${__prev_state}"
    @this.printLine --text ""
}

heading4() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'bold' --state 1
    @this.setProp --prop 'underline' --state 1
    @this.setProp --prop 'fg_colour' --state 'blue'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"

}

heading5() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'bold' --state 1
    @this.setProp --prop 'fg_colour' --state 'blue'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
    # @this.printLine --text ""
    # @this.printLine --text ""
}
heading6() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'underline' --state 1
    @this.setProp --prop 'fg_colour' --state 'blue'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
    # @this.printLine --text ""
    # @this.printLine --text ""
}
figlet() {
    provision.require 'figlet' > /dev/null || {
        echo 'Provision dependency "figlet" is not available in textprint'
    }
    figlet "$1"
}
dim() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'dim' --state 1
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
border() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'dim' --state 1
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
bold() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'bold' --state 1
    @this.print --text "${1}"
    @this.restoreState "${__prev_state}"
}
underline() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'underline' --state 1
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
emphasis() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'emphasis' --state 1
    @this.print --text "${1}"
    @this.restoreState "${__prev_state}"
}
red() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'red'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
blue() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'blue'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
lightBlue() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'light-blue'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
cyan() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'cyan'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
yellow() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'yellow'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
green() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'green'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
orange() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'fg_colour' --state 'orange'
    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}
hr() {
    local defaultChar="@get(@this.theme[@this[themeId]>>hr-char])"
    local char="${1:-$defaultChar}"
    local hr
    string.padding hr "${char}" 80
    @this.printLine --text "${hr}"
}

horiz() {
    local __hText=${1//$'\n'/$'\t'}
    __hText="$(echo "${__hText}" | sed -e 's/\t\+/\t/g')"
    @this.print --text "${__hText}"
}
br() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'remove_nl' --state '0'
    @this.print --text "" --nl 1
    @this.restoreState "${__prev_state}"
}

success() {
    @this.green "$@"
}

warning() {
    @this.orange "$@"
}

danger() {
    @this.red "$@"
}

info() {
    @this.blue "$@"
}

fmt() {
    local __prev_state
    @this.getState __prev_state
    @this.setProp --prop 'remove_nl' --state 1
    @this.setProp --prop 'remove_tab' --state 1

    @this.print --text "$1"
    @this.restoreState "${__prev_state}"
}

graphviz-dot() {
    provision.require 'visual.graphviz.graph_easy' > /dev/null || {
        echo 'Provision dependency "visual.graphviz.graph_easy" is not available'
    }
    graph-easy --from graphviz --as boxart <(echo "$1")
}

box() {
    # Start the box on a new line
    echo ""

    local longest
    # Get length without tags
    longest=$(echo "$1" | sed -e 's/{{[^}}]*}}//g' | wc -L)
    local div_width
    let div_width=longest+2
    local top_line
    string.padding top_line "@get(chars.box['DBL_EW'])" "$div_width"
    echo "$(echo -e @get(chars.box['DBL_SE']))${top_line}$(echo -e @get(chars.box['DBL_SW']))"
    local line_count
    line_count=$(echo "$1" | wc -l)
    local count=0
    local txt_line
    while read -r txt_line; do
        local pdded
        local no_tags
        no_tags=$(echo "$txt_line" | sed -e 's/{{[^}}]*}}//g')
        local no_tags_len=${#no_tags}
        local padstr_len
        let padstr_len=longest-no_tags_len

        string.padding pdded ' ' "$padstr_len"

        let count=count+1
        if [ "$count" == "$line_count" ] \
            && [ "$txt_line" == '' ]
        then
            break;
        else
            echo "$(echo -e @get(chars.box['DBL_NS'])) ${txt_line}${pdded} $(echo -e @get(chars.box['DBL_NS']))"
        fi

    done <<< "$1"
    echo "$(echo -e @get(chars.box['DBL_NE']))${top_line}$(echo -e @get(chars.box['DBL_NW']))"
}

setProp() {
    local -A __params
    __params['prop']=
    __params['state']=
    params.get "$@"
    if [ "@get(@this.state[${__params['prop']}])" == "${__params['state']}" ]; then
        return
    fi
    @set(@this.state["${__params['prop']}"])="${__params['state']}"
    @set(@this.settings['props_changed'])='1'
}
setState() {
    @set(@this.settings['props_changed'])='0'

    local __tkey='default>>'
    # tput sgr0
    @this.setReset
    if [ "@get(@this.state['bold'])" == '1' ]; then
        # tput bold
        @this.setBold
    fi
    if [ "@get(@this.state['dim'])" == '1' ]; then
        # tput dim
        @this.setDim
    fi
    if [ "@get(@this.state['underline'])" == '1' ]; then
        # tput smul
        @this.setUnderline
    else
        # tput rmul
        @this.setRemoveUnderline
    fi
    if [ "@get(@this.state['emphasis'])" == '1' ]; then
        # tput smso
        @this.setEm
    else
        # tput rmso
        @this.setRemoveEm
    fi

    if [ "@get(@this.state['fg_colour'])" == 'red' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>red])"
    elif [ "@get(@this.state['fg_colour'])" == 'blue' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>blue])"
    elif [ "@get(@this.state['fg_colour'])" == 'yellow' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>yellow])"
    elif [ "@get(@this.state['fg_colour'])" == 'green' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>green])"
    elif [ "@get(@this.state['fg_colour'])" == 'orange' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>orange])"
    elif [ "@get(@this.state['fg_colour'])" == 'light-blue' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>light-blue])"
    elif [ "@get(@this.state['fg_colour'])" == 'cyan' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>cyan])"
    elif [ "@get(@this.state['fg_colour'])" == 'default' ]; then
        tput setaf "@get(@this.theme[@this[themeId]>>default])"
    fi
}

setBold() {
    echo -n "@get(@this.cached['bold'])"
}

setDim() {
    echo -n "@get(@this.cached['dim'])"
}

setReset() {
    echo -n "@get(@this.cached['reset'])"
}

setUnderline() {
    echo -n "@get(@this.cached['underline'])"
}

setRemoveUnderline() {
    echo -n "@get(@this.cached['removeUnderline'])"
}

setEm() {
    echo -n "@get(@this.cached['em'])"
}

setRemoveEm() {
    echo -n "@get(@this.cached['removeEm'])"
}

print() {
    local -A __params
    __params['text']=
    __params['nl']=0
    __params['block']=0
    params.get "$@"



    if [ "@get(@this.settings['props_changed'])" == '1' ]; then
        @this.setState
    fi
    local __textp
    __textp="${__params['text']}"

    if [ "@get(@this.state['remove_nl'])" == '1' ] \
        && [ "${__params['block']}" != '1' ]
    then
        __textp=${__textp//$'\n'/}
    fi

    if [ "@get(@this.state['remove_tab'])" == '1' ]; then
        __textp=${__textp//$'\t'/}
    fi

    if [ "${__params['block']}" == '1' ]; then
        echo ""
    fi

    @this.moPrint "${__textp}"

    if [ "${__params['block']}" == '1' ]; then
        echo ""
    fi

    if [ "${__params['nl']}" == '1' ]; then
        echo ""
    fi
}

printLine() {
    @this.print "$@" --nl 1
}

getState() {
    local __ret_var=$1
    local __prev_state_data=$(@arrStr(@this.state))
    __prev_state_data=${__prev_state_data/-A/-A -g}
    string.return_value "$__prev_state_data" $__ret_var
}
restoreState() {
    eval "$1"
    @this.setState
}

# Override functionality in the mo vendor script
__global::moIsFunction() {
    # JC - replaced function with this as the previous method
    # would become exponentially slower with the number of
    # functions in scope
    declare -f -F $1 > /dev/null
    return $?
}
moPrint() {
    local IFS=$' \n\t'
    moParse "$1" "" false
}
