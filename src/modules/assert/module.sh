@namespace

    functionExists::args() {
        parameters.add --key 'name' \
            --namespace '@this.functionExists' \
            --name 'Funtion Name' \
            --alias '-n' \
            --alias '--name' \
            --desc 'The name of the function to check for.' \
            --required '1' \
            --has-value 'y'

        parameters.add --key 'not' \
            --namespace '@this.functionExists' \
            --name 'Not' \
            --alias '--not' \
            --desc 'Invert the result of the check.' \
            --required '0' \
            --type 'switch' \
            --has-value 'n'

        parameters.add --key 'description' \
            --namespace '@this.functionExists' \
            --name 'Description' \
            --alias '--desc' \
            --desc 'A description of the purpose of the check.' \
            --required '0' \
            --has-value 'y'
    }

    functionExists() {
        @=>params
        logger.print \
            --prefix 'TEST' \
            --no-newline '1' \
            --message \
            "Checking that the function '@params[name]' exists"
        declare -f -F "@params[name]" > /dev/null
        local result="$?"
        @this.handleResult "$result"

    }

    stringEquals::args() {
        parameters.add --key 'expected' \
            --namespace '@this.stringEquals' \
            --name 'Expected' \
            --alias '--expected' \
            --desc 'The expected string value' \
            --required '1' \
            --has-value 'y'

        parameters.add --key 'actual' \
            --namespace '@this.stringEquals' \
            --name 'Actual' \
            --alias '--actual' \
            --desc 'The actual string value' \
            --required '1' \
            --has-value 'y'

        parameters.add --key 'not' \
            --namespace '@this.stringEquals' \
            --name 'Not' \
            --alias '--not' \
            --desc 'Invert the result of the check.' \
            --required '0' \
            --type 'switch' \
            --has-value 'n'

        parameters.add --key 'description' \
            --namespace '@this.stringEquals' \
            --name 'Description' \
            --alias '--desc' \
            --desc 'A description of the purpose of the check.' \
            --required '0' \
            --has-value 'y'
    }

    stringEquals() {
        @=>params
        logger.print \
            --prefix 'TEST' \
            --no-newline '1' \
            --message \
            "Checking that the string '@params[expected]' is '@params[actual]' exists"
        [ "@params[expected]" == "@params[actual]" ]
        local result="$?"
        @this.handleResult "$result"

    }

    handleResult() {
        local assertResult="$1"
        if [ "@params[not]" == '1' ]; then
            if [ "${assertResult}" == '0' ]; then
                assertResult=1
            else
                assertResult=0
            fi
        fi
        if [ "$assertResult" == 1 ]; then
            logger.print --message ' - FAIL' --no-newline '0'
            logger.stackTrace \
                --message "@params[description]"
        else
            logger.print --message ' - PASS' --no-newline '0'
        fi
		return $assertResult
    }
