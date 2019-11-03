
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
        --type 'file_exists' \
        --excludes '@this.main::module_name'

    parameters.add --key 'module_name' \
        --namespace '@this.main' \
        --name 'Module Name' \
        --alias '-m' \
        --alias '--module' \
        --desc 'The name of the module to document' \
        --required '1' \
        --has-value 'y'

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
}

main() {
    @=>params
    logger.info --message 'Example 1'
}
