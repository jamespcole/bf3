import.require '.t1' as 'tests.suites.namespace.t1'
import.require '.t2' as 'tests.suites.namespace.t2'
import.require 'assert'

tests.suites.namespace.init() {
    tests.suites.namespace.test::namespaceInitExists() {
        assert.functionExists \
            --name 'tests.suites.namespace.t1.init' \
            --desc 'The init function should exist'
    }
    tests.suites.namespace.test::namespacedFunctionExists() {
        assert.functionExists \
            --name 'tests.suites.namespace.t1.newFunc' \
            --desc 'The namespaced child function should exist'
    }
    tests.suites.namespace.test::asAliasCreated() {
        assert.functionExists \
            --name 'tests.suites.namespace.t2.t1.as.newName.init' \
            --desc 'The init function for the "as" alias should exist'
    }
}
