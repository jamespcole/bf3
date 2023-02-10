#!/usr/bin/env bash
import.require 'logger.handlers.formatted'
import.require '@rel==.docs' as '@this.docs'

@namespace

__init() {
    logger.setConsoleLogHandler \
        --namespace 'logger.handlers.formatted'
}

hatWobble() {
    logger.info \
        --message "WOBBLE@params[example]"
}

main::args() {
    parameters.add --key 'example' \
        --namespace '@this.main' \
        --name 'Example Arg' \
        --alias '--example' \
        --alias '-e' \
        --desc 'An example argument.' \
        --default '!!!' \
        --has-value 'y'
}

main() {
    @=>params
    @this.hatWobble
}