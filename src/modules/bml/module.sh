#!/usr/bin/env bash

import.require 'bml.shell' as '@this.shell'
import.require 'bml.markdown' as '@this.markdown'

resource.relative '@rel==docs/example.bml' into '@this'

@namespace

@this[output]='@this.shell'

__global::b:u() {
    "@this[output]".underline "$@"
}
__global::b:b() {
    "@this[output]".bold "$@"
}
__global::b:d() {
    "@this[output]".dim "$@"
}
__global::b:list() {
    "@this[output]".list "$@"
}
__global::b:li() {
    "@this[output]".listItem "$@"
}
__global::b:in() {
    "@this[output]".indent "$@"
}
__global::b:h1() {
    "@this[output]".heading1 "$@"
}
__global::b:h2() {
    "@this[output]".heading2 "$@"
}
__global::b:h3() {
    "@this[output]".heading3 "$@"
}
__global::b:h4() {
    "@this[output]".heading4 "$@"
}
__global::b:h5() {
    "@this[output]".heading5 "$@"
}
__global::b:h6() {
    "@this[output]".heading6 "$@"
}
__global::b:hr() {
    "@this[output]".hr "$@"
}
__global::b:box() {
    "@this[output]".box "$@"
}
__global::b:fmt() {
    "@this[output]".fmt "$@"
}
__global::b:horiz() {
    "@this[output]".horiz "$@"
}
__global::b:br() {
    "@this[output]".br "$@"
}
__global::b:em() {
    "@this[output]".emphasis "$@"
}
__global::b:success() {
    "@this[output]".success "$@"
}
__global::b:danger() {
    "@this[output]".danger "$@"
}
__global::b:info() {
    "@this[output]".info "$@"
}
__global::b:warning() {
    "@this[output]".warning "$@"
}

__global::b:icon() {
    "@this[output]".icon "$@"
}
__global::b:figlet() {
    "@this[output]".figlet "$@"
}
__global::b:graphviz-dot() {
    "@this[output]".graphviz-dot "$@"
}

main::args() {
    parameters.add --key 'inputFile' \
        --namespace '@this.main' \
        --name 'Input File' \
        --alias '--input-file' \
        --alias '-i' \
        --desc 'The path to a bml file to parse' \
        --required-unless '@this.main::example' \
        --excludes '@this.main::example' \
        --has-value 'y' \
        --type 'file_exists'

    parameters.add --key 'example' \
        --namespace '@this.main' \
        --name 'Show BML Example' \
        --alias '--example' \
        --desc 'Shows some examples of how to use BML and what the output will look like.' \
        --required-unless '@this.main::inputFile' \
        --excludes '@this.main::inputFile' \
        --has-value 'm' \
        --default 'simple' \
        --enum-value 'simple' \
        --type 'enum'

    parameters.add --key 'margin' \
        --namespace '@this.main' \
        --name 'Add a margin' \
        --alias '--margin' \
        --alias '-m' \
        --desc 'Adds a left margin to all output.  The default is 2 space.' \
            + '  Is used when using "TERM" as the output format.' \
        --has-value 'm' \
        --default '  '

    parameters.add --key 'format' \
        --namespace '@this.main' \
        --name 'Output Format' \
        --alias '--format' \
        --alias '-F' \
        --desc 'The output format to use, at the moment terminal "TERM"(default)' \
            + ' and markdown "MD" and "RAW" are supported.' \
        --required '0' \
        --has-value 'y' \
        --enum-value 'TERM' \
        --enum-value 'MD' \
        --enum-value 'RAW' \
        --default 'TERM' \
        --type 'enum'

    parameters.add --key 'outputFile' \
        --namespace '@this.main' \
        --name 'Output File' \
        --alias '--out-file' \
        --alias '-o' \
        --desc 'The path of a file to write the generated document to.' \
        --required '0' \
        --has-value 'y'

    parameters.add --key 'clearOutput' \
        --namespace '@this.main' \
        --name 'Clear Screen' \
        --alias '--clear' \
        --alias '-c' \
        --desc 'If passed this will clear the terminal before printing.' \
        --required '0' \
        --has-value 'n'

}

main() {
    @=>params
    if [ @params[format] == 'MD' ]; then
        @this[output]='@this.markdown'
    fi

    if [ @params[format] != 'TERM' ]; then
        # Margin only supported with TERM output
        @params[margin]=''
    fi
    if [ "@params[clearOutput>>specified]" == '1' ] \
        && [ "@params[format]" == 'TERM' ]; then
        clear
        clear
    fi

    local raw
    if [ "@params[example>>specified]" == '1' ]; then
        raw=$(@this.printExample)
    else
        raw="$(cat @params[inputFile])"
    fi
    local processed
    if [ "@params[format]" == 'RAW' ]; then
        processed="$raw"
    else
        processed=$(@this.printFile \
            --text "$raw" \
            --margin "@params[margin]")
    fi

    if [ "@params[outputFile>>specified]" == '1' ]; then
        echo "${processed}" > "@params[outputFile]"
    else
        echo "${processed}"
    fi
}

printExample() {
    echo "$(@this.resource.get 'docs/example.bml')"
}

printFile::args() {
    parameters.add --key 'text' \
        --namespace '@this.printFile' \
        --name 'Raw BML Text' \
        --alias '--text' \
        --desc 'The raw BML text to process.' \
        --required '1' \
        --has-value 'y'

    parameters.add --key 'margin' \
        --namespace '@this.printFile' \
        --name 'Add a margin' \
        --alias '--margin' \
        --alias '-m' \
        --desc 'Adds a left margin to all output.  The default is 2 space.' \
            + '  Is used when using "TERM" as the output format.' \
        --has-value 'm' \
        --default '  '
}

printFile() {
    @=>*params
    @this.preProcess --text "@params[text]" | sed "s/^/@params[margin]&/"
}

print() {
    @this.preProcess "$@"
}

preProcess::args() {
    parameters.add --key 'text' \
        --namespace '@this.preProcess' \
        --name 'Raw BML Text' \
        --alias '--text' \
        --desc 'The raw BML text to process.' \
        --required '1' \
        --has-value 'y'
}

preProcess() {
    @=>*params
    local processedStr
    processedStr=$(@this.printIteration1 "@params[text]")
    processedStr=$(@this.printIteration2 "${processedStr}")
    processedStr=$(@this.printIteration3 "${processedStr}")
    echo -n "${processedStr}"
}


printIteration1() {
    # In this itertion we prepare the run before tags,
    # eg: "{<{" and "}<}"
    # First switch the "{{" and "}}" delimiters to placeholders
    local outStr="$1"
    # Swap "{{" and "}}" to "{#{" "}#}"
    local startDelim='{{'
    local startTempDelim='{#{'
    local endDelim='}}'
    local endTempDelim='}#}'
    local startStepDelim='{<{'
    local endStepDelim='}<}'
    local startLiteralDelim='{!<{'
    local endLiteralDelim='}!<}'

    outStr="${outStr//$startDelim/$startTempDelim}"
    outStr="${outStr//$endDelim/$endTempDelim}"

    outStr="${outStr//$startStepDelim/$startDelim}"
    outStr="${outStr//$endStepDelim/$endDelim}"

    outStr=$("@this[output]".print --text "$outStr")

    outStr="${outStr//$startTempDelim/$startDelim}"
    outStr="${outStr//$endTempDelim/$endDelim}"

    outStr="${outStr//$startLiteralDelim/$startStepDelim}"
    outStr="${outStr//$endLiteralDelim/$endStepDelim}"

    echo -n "${outStr}"
}

printIteration2() {
    # In this itertion we prepare the run after tags,
    # eg: "{>{" and "}>}"
    local outStr="$1"
    local startDelim='{{'
    local endDelim='}}'
    local startStepDelim='{>{'
    local endStepDelim='}>}'
    local startLiteralDelim='{!>{'
    local endLiteralDelim='}!>}'

    outStr="${outStr//$startStepDelim/$startDelim}"
    outStr="${outStr//$endStepDelim/$endDelim}"

    outStr=$("@this[output]".print --text "$outStr")

    outStr="${outStr//$startLiteralDelim/$startStepDelim}"
    outStr="${outStr//$endLiteralDelim/$endStepDelim}"

    echo -n "${outStr}"
}

printIteration3() {
    # In this itertion we swap out the non-parse tags,
    # eg: "{!{" and "}!}"
    local outStr="$1"
    local startDelim='{{'
    local endDelim='}}'
    local startStepDelim='{!{'
    local endStepDelim='}!}'
    local startLiteralDelim='{!!{'
    local endLiteralDelim='}!!}'

    outStr="${outStr//$startStepDelim/$startDelim}"
    outStr="${outStr//$endStepDelim/$endDelim}"

    outStr="${outStr//$startLiteralDelim/$startStepDelim}"
    outStr="${outStr//$endLiteralDelim/$endStepDelim}"

    echo -n "${outStr}"
}

loadTheme() {
    "@this[output]".loadTheme "$@"
}
