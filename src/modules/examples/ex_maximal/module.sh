#!/usr/bin/env bash
import.require 'logger.handlers.formatted'

@namespace

__init() {
    logger.setConsoleLogHandler \
        --namespace 'logger.handlers.formatted'
}

hatWobble() {
    logger.info \
        --message "WOBBLE@params[suffix]"
}

main::args() {
    parameters.add --key 'suffix' \
        --namespace '@this.main' \
        --name 'Message Suffix' \
        --alias '--suffix' \
        --alias '-s' \
        --desc 'Specify the suffix for the message.' \
        --default '!!!' \
        --has-value 'y'
}

main() {
    @=>params
    @this.hatWobble
}