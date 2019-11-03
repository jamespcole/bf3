import.require '@rel==.t2' as '@this.t2'
import.require 'assert'

@namespace
    test::setAndGetVars() {

        assert.stringEquals \
            --expected 'testVar1 set in t2' \
            --actual "@get->@this.t2[testVar1]" \
            --desc 'Accessing ns vars from outside the namespace works'

        @set->@this.t2[testVar1]='Set from outside namespace'
        assert.stringEquals \
            --expected 'Set from outside namespace' \
            --actual "@get->@this.t2[testVar1]" \
            --desc 'Setting ns vars from outside the namespace works'

        assert.stringEquals \
            --expected 'one' \
            --actual "@get(@this.t2.newVar[0])" \
            --desc 'Creating an array on the namespace'

        @set(@this.t2.newVar[1])='Array element set from outside namespace'
		assert.stringEquals \
			--expected 'Array element set from outside namespace' \
			--actual "@get(@this.t2.newVar[1])" \
			--desc 'Setting an array element on the namespace'
    }
