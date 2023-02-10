#!/usr/bin/env bash

@namespace

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