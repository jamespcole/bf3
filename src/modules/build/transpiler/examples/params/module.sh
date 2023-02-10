@namespace

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
    echo "The suffix is @params[suffix]"
    @params[suffix]='123'
    echo "The suffix is now @params[suffix]"
}
