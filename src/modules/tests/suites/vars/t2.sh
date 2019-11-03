
@namespace

@this[testVar1]='testVar1 set in t2'
@create[](@this.newVar)=('one' 'two')
newFunc2() {
    echo "newFunc2 in t2"
}


echoTestVar1() {
    echo "@this[testVar1]"
}

echoTestVar2() {
    echo "@this[testVar2]"
}
