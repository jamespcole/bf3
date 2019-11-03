import.require '@rel==.ref1' as '@this.ref1'
import.require '@rel==.ref2' as '@this.ref2'
import.require '@rel==.ref2' as '@this.ref3'
import.require 'assert'

@namespace
    test::reference() {

        @this.ref2.ref.setTarget '@this.ref1'
        assert.functionExists \
            --name 'tests.suites.reference.ref2.ref.newFunc' \
            --desc 'The functions on the referenced namespace should be available via the reference'

        assert.stringEquals \
            --expected 'newFunc in ref1' \
            --actual "$(@this.ref2.ref.newFunc)" \
            --desc 'Calling a function on the referenced namespace'

        assert.stringEquals \
            --expected 'testVar1 set in ref1' \
            --actual "@get->@this.ref2.ref[testVar1]" \
            --desc 'Accessing a variable on the referenced namespace'

        @this.ref2.ref.setTarget '@this.ref3'
        assert.stringEquals \
            --expected 'testVar1 set in ref2' \
            --actual "@get->@this.ref2.ref[testVar1]" \
            --desc 'Accessing a variable on the referenced namespace after target changed'
    }
