import.require '@rel==.t2' as '@this.t2'
import.require 'assert'

@namespace
    test::loadMixin() {

        assert.functionExists \
            --name 'tests.suites.mixin.t2.init' \
            --desc 'The init function should exist for the namespace having the mixin added to it'
        assert.functionExists \
            --name 'tests.suites.mixin.t2.mixin.t1.init' \
            --desc 'The init function should exist for the mixin'

        assert.functionExists \
            --name 'tests.suites.mixin.t2.newFunc' \
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
