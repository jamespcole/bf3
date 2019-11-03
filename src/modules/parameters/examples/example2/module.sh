
@namespace

main::args() {
    parameters.add --key 'input_file' \
        --namespace '@this.main' \
        --name 'Input File' \
        --alias '-i' \
        --alias '--input-file' \
        --desc 'The input template file' \
        --required '0' \
        --has-value 'y' \
        --excludes '@this.main::module_name'

    parameters.add --key 'save_file' \
        --namespace '@this.main' \
        --name 'Save File' \
        --alias '-s' \
        --alias '--save' \
        --desc 'Automatically save the docs file' \
        --type 'switch' \
        --default '0' \
        --has-value 'n'

    parameters.add --key 'includes_test' \
        --namespace '@this.main' \
        --name 'Include Test' \
        --alias '-t' \
        --alias '--test' \
        --desc 'Test including another param' \
        --type 'switch' \
        --default '0' \
        --has-value 'n' \
        --includes '@this.main::save_file'

    parameters.add --key 'required_unless_test' \
        --namespace '@this.main' \
        --name 'Required Unless Test' \
        --alias '-r' \
        --alias '--req-u' \
        --desc 'Test requiring unless another param' \
        --type 'switch' \
        --default '0' \
        --has-value 'n' \
        --required-unless '@this.main::save_file'
}

main() {
    @=>params
    logger.info --message 'Example 2'
}
