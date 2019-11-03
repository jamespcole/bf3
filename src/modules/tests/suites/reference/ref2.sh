import.require 'reference' as '@this.ref'

@namespace

@this[testVar1]='testVar1 set in ref2'

newFunc2() {
    echo "newFunc2 in ref2"
}

newFunc2() {
    echo "newFunc2 in ref2"
}

newFunc3() {
    echo "newFunc3 in ref2";
}

echoTestVar1() {
    echo "@this[testVar1]"
}

echoTestVar2() {
    echo "@this[testVar2]"
}
