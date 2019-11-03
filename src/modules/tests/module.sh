import.require 'tests.suites.namespace'
import.require 'tests.suites.mixin'
import.require 'tests.suites.vars'
import.require 'tests.suites.extend'
import.require 'tests.suites.reference'
import.require 'tests.suites.transpile'

tests.init() {
    tests.main() {
        # tests.suites.namespace.test::namespaceInitExists
        # tests.suites.namespace.test::namespacedFunctionExists
        # tests.suites.namespace.test::asAliasCreated
        #
        # tests.suites.mixin.test::loadMixin
		# tests.suites.vars.test::setAndGetVars
        #
        tests.suites.extend.test::loadExtend
        tests.suites.extend.test::superCalls
        #
        # tests.suites.reference.test::reference

        # tests.suites.transpile.test::namespace

        # declare -f 'tests.suites.reference.ref2.ref.init'
    }
}
