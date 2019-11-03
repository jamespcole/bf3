import.require 'resource'

@namespace
test() {
    echo "test";
}


testInner() {
    echo "test";
    testInner.testing() {
        echo "tetsting"
        @this.test
    }
}
