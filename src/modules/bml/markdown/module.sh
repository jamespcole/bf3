import.require 'chars'
import.require 'mustache'
import.require 'string'
import.require 'provision.figlet'
import.require 'provision.visual.graphviz'

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

@create{}(@this.settings)
@set(@this.settings['props_changed'])='0'

@this[themeId]='default'
@create{}(@this.theme)

__init() {
    @this.loadTheme
}

loadTheme() {

    @set(@this.theme["@this[themeId]>>icon_danger"])="@get(chars.figs['SKULL']) "
    @set(@this.theme["@this[themeId]>>icon_info"])="@get(chars.figs['INFO_ROUND']) "
    @set(@this.theme["@this[themeId]>>icon_warning"])="@get(chars.figs['WARN']) "
    @set(@this.theme["@this[themeId]>>icon_success"])="@get(chars.figs['TICK']) "
}



indent() {
    echo "$1" | sed 's/^/    &/'
}
list() {
    # Indent all lines by two spaces.  This will also prefix nested list items.
    # The call stack ensures that each level will be indented the right amount.
    # As a list item will pass through here for each of its parent list.
    # eg. a three level nested list item will pass through here 3 times during
    # the render by handlebars.
    echo "$1" | sed 's/^./  &/'
}
listItem() {
    # Assumes the parent lists have been adding the indent
    # during parsing
    echo "* $1"
}

# The following much more complex list handing implementations
# can be used if issues arise with the amount of whitespace
# allowed before list items before they are interpreted as indented
# block or sub items.  It can vary a lot between editors/renderers
# whle the above simple implementation leaves extra space at the
# beginning of the root list items it isn't casuing an issue in most
# markdown implementations tested so far.
list_complex() {
    local returnList="${1}"
    if [[ "$1" == *'{{#b:list}}'* ]]; then
        local lStart='{{#b:list}}'
        local lEnd='{{/b:list}}'
        local beforePart="${1%%$lStart*}"
        local afterPart="${1##*$lEnd}"

        local childLists="${1#*$lStart}"
        childLists="${childLists%$lEnd*}"
        returnList="${childLists//'{{#b:li}}'/'{{#b:li}}[[nestLevel]]'}"
        returnList="${beforePart}${lStart}${returnList}${lEnd}${afterPart}"
    fi
    # echo "$1" | sed 's/^ \(.*[ ]\) \([^ ].*\)$/\1 * \2/'
    echo "${returnList}"
}
listItem_complex() {
    # We need to check if this is part of a nested list.
    # If it is the parent list elements will have already
    # added "[[nestLevel]]" to the beginng of text inside
    # the li tag we are now processing.  We just need to
    # split the string on the last occurance of "[[nestLevel]]"
    # insert the Markdown list item character to it and then
    # add a space to the beginning of the result for each
    # occurance of [[nestLevel]] to give the correct format
    # for markdown.


    local cleaned="${1##*'[[nestLevel]]'}"
    local nested="${1/$cleaned/}"
    echo "${nested//'[[nestLevel]]'/ }* $cleaned"
}

icon() {
    echo "$(echo -en @get(@this.theme[@this[themeId]>>icon_$1]))"
}

heading1() {
    @this.printLine --text "# ${1}"
    @this.printLine --text ""
}
heading2() {
    @this.printLine --text "## ${1}"
    @this.printLine --text ""
}
heading3() {
    @this.printLine --text "### ${1}"
    @this.printLine --text ""
}
heading4() {
    @this.printLine --text "#### ${1}"
    @this.printLine --text ""
}
heading5() {
    @this.printLine --text "##### ${1}"
    @this.printLine --text ""
}
heading6() {
    @this.printLine --text "###### ${1}"
    @this.printLine --text ""
}
figlet() {
    provision.require 'figlet' > /dev/null || {
        echo 'Provision dependency "figlet" is not available in textprint'
    }
    @this.printLine --text '```'
    figlet "$1"
    @this.printLine --text '```'
}
dim() {
    echo "$1"
}
bold() {
    @this.print --text "__${1}__"
}
underline() {
    # NOTE: underline isn't generally supported in
    # markdown so "em" is sed instead
    @this.print --text "_${1}_"
}
emphasis() {
    @this.print --text "_${1}_"
}
red() {
    echo "$1"
}
blue() {
    echo "$1"
}
lightBlue() {
    echo "$1"
}
cyan() {
    echo "$1"
}
yellow() {
    echo "$1"
}
green() {
    echo "$1"
}
orange() {
    echo "$1"
}
hr() {
    @this.printLine --text '---'
}

horiz() {
    local trimmedText
    string.trim trimmedText "$1"
    local hText=${trimmedText//$'\n'/$'\t'}
    hText="$(echo "${hText}" | sed -e 's/\t\+/\t/g')"
    # Markdown interperets the leading whitespace as a code block
    # so we need to trim it first
    @this.print --text "${hText/\\t/}"
}
br() {
    @this.printLine --text ""
}

success() {
    echo "$1"
}

warning() {
    echo "$1"
}

danger() {
    echo "$1"
}

info() {
    echo "$1"
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
    provision.require 'visual.graphviz' > /dev/null || {
        echo 'Provision dependency "visual.graphviz" is not available'
    }
    # For markdown we convert the dot markup to png then base 64 encode
    # it so it can be directly embedded into the markdown file.
    echo "![Diagram](data:image/jpeg;base64,$(dot -Tpng <(echo "$1") | base64 -w 0))"
}

box() {
    # For markdown we just convert to a blockqoute element
    echo ""
    echo "$1" | fmt -w 80 | sed 's/^/> /'
    echo ""
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
    # State resetting not really needed for markdown so this is
    # really just a stub
    local __tkey='default>>'
    @set(@this.settings['props_changed'])='0'
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
