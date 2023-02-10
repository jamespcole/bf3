# import.require '.t1' as 'tests.suites.namespace.t1'
# import.require '.t2' as 'tests.suites.namespace.t2'
import.require 'assert'
import.require 'build.transpiler'

tests.suites.transpile.init() {
    # tests.suites.transpile.test::namespace() {
    #     local absPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
    #     build.transpiler.transpile "${absPath}/t1.sh" 'base.ns' 'extend' 'test1.test2'
    #     local sourceFile="$1"
    #     local nSpace="$2"
    #     local nSpaceOuter="$3"
    #     local operation="$4:-import"
    #     local originalNamespace="$4:-import"
    #     assert.functionExists \
    #         --name 'tests.suites.namespace.t1.init' \
    #         --desc 'The init function should exist'
    #     # build.transpiler.transpile "${absPath}/t3.sh" 't3' 'extend' 'test1.syntax' | grep -q 'SYNTAX ERROR' || {
    #     #     echo "Failed"
    #     # }
    # }
    tests.suites.transpile.test::namespacedFunctionExists() {
        assert.functionExists \
            --name 'tests.suites.namespace.t1.newFunc' \
            --desc 'The namespaced child function should exist'
    }
    tests.suites.transpile.test::asAliasCreated() {
        assert.functionExists \
            --name 'tests.suites.namespace.t2.t1.as.newName.init' \
            --desc 'The init function for the "as" alias should exist'
    }
}
