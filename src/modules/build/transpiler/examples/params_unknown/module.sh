@namespace

example::args() {
    parameters.add --key 'example' \
        --namespace '@this.example' \
        --name 'Message Suffix' \
        --alias '--example' \
        --alias '-e' \
        --desc 'An example argument' \
        --default '!!!' \
        --has-value 'y'
}

example() {
    @=>params
    echo "The example value is @params[example]"
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
    @=>*params
    echo "The suffix is @params[suffix]"
    # Now pass the unknown parameters into the next function
    @this.example "${unknown[@]}"
}
