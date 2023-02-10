import.require 'assert'
import.require 'build.transpiler'


@namespace

test::setting() {
    @this.newFunc --example 'test'
    @this.newFunc2 --example
}

newFunc::args() {
    parameters.add --key 'example' \
        --namespace '@this.newFunc' \
        --name 'Example Arg' \
        --alias '--example' \
        --alias '-e' \
        --desc 'An example argument.' \
        --required '1' \
        --has-value 'y'
}

newFunc() {
    @=>params
    assert.stringEquals \
        --expected 'test' \
        --actual "@params[example]" \
        --desc 'Parameter "example" was set to correct value'
}


newFunc2::args() {
    parameters.add --key 'example' \
        --namespace '@this.newFunc2' \
        --name 'Example Arg' \
        --alias '--example' \
        --alias '-e' \
        --desc 'An example argument.' \
        --required '1' \
        --has-value 'y'
}

newFunc2() {
    
    local ignoreErrors=true
    @=>params
    # echo "${paramErrors[*]}"
    assert.stringEquals \
        --expected 'The argument "Example Arg(--example,-e)" requires a value' \
        --actual "${paramErrors[0]}" \
        --desc 'Parameter "example" was set to correct value'
}

