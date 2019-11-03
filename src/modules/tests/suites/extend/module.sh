import.require '@rel==.t2' as '@this.t2'
import.require '@rel==.t3' as '@this.t3'
import.require 'assert'

@namespace
test::loadExtend() {
    assert.functionExists \
        --name 'tests.suites.extend.t2.init' \
        --desc 'The init function should exist for the namespace having the mixin added to it'

    assert.functionExists \
        --name 'tests.suites.extend.t2.extend.t1.init' \
        --desc 'The init function should exist for the mixin'

    assert.functionExists \
        --name 'tests.suites.extend.t2.newFunc' \
        --desc 'The function from the mixin should exist in the target namespace'

    assert.stringEquals \
        --expected 'newFunc in t1' \
        --actual "$(@this.t2.newFunc)" \
        --desc 'Calling the function from the mixin on the mixin target returns the correct value'

    assert.stringEquals \
        --expected 'newFunc2 in t2' \
        --actual "$(@this.t2.newFunc2)" \
        --desc 'Overriding a function in the mixin target is working'

    assert.stringEquals \
        --expected 'newFunc3 in t1newFunc3 in t2' \
        --actual "$(@this.t2.newFunc3)" \
        --desc 'Calls to super call the extended namespaces functions'

    assert.stringEquals \
        --expected 'testVar1 set in t2' \
        --actual "$(@this.t2.echoTestVar1)" \
        --desc 'Overriding a namesapce variable works'

    assert.stringEquals \
        --expected 'testVar2 set in t1' \
        --actual "$(@this.t2.echoTestVar2)" \
        --desc 'Inheriting a namesapce variable works'

    assert.stringEquals \
        --expected 'testVar2 set in t1' \
        --actual "@get->@this.t2[testVar2]" \
        --desc 'Accessing ns vars from outside the namespace works'
}

test::superCalls() {

    # declare -F | grep 'tests.suites.extend.t3' | grep 'newFunc$'



    while read -r line; do
        $line
    done <<< "$(declare -F | grep 'tests.suites.extend.t3' | grep 'newFunc$')"


    echo "----------------------"

    while read -r line; do
        $line
    done <<< "$(declare -F | grep 'tests.suites.extend.t3' | grep 'newFunc3')"

    echo "----------------------"

    while read -r line; do
        $line
    done <<< "$(declare -F | grep 'tests.suites.extend.t3' | grep 'newFunc2')"

    echo "----------------------"

    # declare -f tests.suites.extend.t3.newFunc
    # declare -f tests.suites.extend.t3.super.newFunc
    # declare -f tests.suites.extend.t3.super.t1.newFunc
    #
    #
    # declare -f tests.suites.extend.t3.newFunc3
    # declare -f tests.suites.extend.t3.super.newFunc3
    # declare -f tests.suites.extend.t3.super.t1.newFunc3
    # declare -f tests.suites.extend.t3.super.t2.newFunc3



    #
    echo "----------------------"
    #
    # declare -f tests.suites.extend.t3.newFunc3
    # declare -f tests.suites.extend.t3.super.newFunc3
    # declare -f tests.suites.extend.t3.super.t2.newFunc3
    # declare -f tests.suites.extend.t3.super.t2.super.t1.newFunc3
    #
    # declare -f tests.suites.extend.t3._super.t2.super.newFunc
    # declare -f tests.suites.extend.t3._super.t2.super.t1.newFunc
    # declare -f tests.suites.extend.t3.newFunc
    #
    # echo "----------------------"
    #
    # declare -f tests.suites.extend.t3._super.t2.super.newFunc3
    # declare -f tests.suites.extend.t3._super.t2.super.t1.newFunc3
    # declare -f tests.suites.extend.t3.newFunc3
    # declare -f tests.suites.extend.t3.super.newFunc3
    # declare -f tests.suites.extend.t3.super.t2.newFunc3




#     declare -f tests.suites.extend.t3.newFunc
# declare -f tests.suites.extend.t3.super.t2.newFunc
# declare -f tests.suites.extend.t3.super.t2.super.newFunc
# declare -f tests.suites.extend.t3.super.t2.super.t1.newFunc

    # declare -f tests.suites.extend.t3.newFunc
    # declare -f tests.suites.extend.t3.newFunc2
    # declare -f tests.suites.extend.t3.newFunc3
    # declare -f tests.suites.extend.t3.super.newFunc2
    # declare -f tests.suites.extend.t3.super.newFunc3
    # declare -f tests.suites.extend.t3.super.t2.newFunc
    # declare -f tests.suites.extend.t3.super.t2.newFunc2
    # declare -f tests.suites.extend.t3.super.t2.newFunc3
    # declare -f tests.suites.extend.t3.super.t2.super.newFunc
    # declare -f tests.suites.extend.t3.super.t2.super.newFunc2
    # declare -f tests.suites.extend.t3.super.t2.super.newFunc3
    # declare -f tests.suites.extend.t3.super.t2.super.t1.newFunc
    # declare -f tests.suites.extend.t3.super.t2.super.t1.newFunc2
    # declare -f tests.suites.extend.t3.super.t2.super.t1.newFunc3

    assert.functionExists \
        --name 'tests.suites.extend.t3._super.newFunc' \
        --desc 'The function from the super should exist in the target namespace'

    assert.stringEquals \
        --expected 'newFunc in t1\nadded in t3' \
        --actual "$(@this.t3.newFunc)" \
        --desc 'Calling the function from the mixin on the mixin target returns the correct value'

    assert.stringEquals \
        --expected 'newFunc2 in t2' \
        --actual "$(@this.t3.newFunc2)" \
        --desc 'Overriding a function in the exend target is working'


    # declare -f 'tests.suites.extend.t3.super.t2.newFunc3'
    assert.stringEquals \
        --expected 'newFunc3 in t1newFunc3 in t2' \
        --actual "$(@this.t3.newFunc3)" \
        --desc 'Calls to super call the extended namespaces functions'

}
