#!/usr/bin/env bash
echo "Test 0"
bf3 --run 'parameters.examples.example1' && {
	echo "should have failed"
}
echo "Test 1"
bf3 --run 'parameters.examples.example1' --module && {
	echo "should have failed"
}
echo "Test 2"
bf3 --run 'parameters.examples.example1' --module 'tttt' || {
	echo "should have passed"
}
echo "Test 3"
bf3 --run 'parameters.examples.example1'  --module 'tttt' -i 'tttt' && {
	echo "should have failed"
}

echo "Test 4"
bf3 --run 'parameters.examples.example1'  --module 'tttt' -t && {
	echo "should have failed"
}

echo "Test 5"
bf3 --run 'parameters.examples.example1'  --module 'tttt' -t -s || {
	echo "should have passed"
}

echo "Test 6"
bf3 --run 'parameters.examples.example2'  -i 'test' && {
	echo "should have failed"
}
