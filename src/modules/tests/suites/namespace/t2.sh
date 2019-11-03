import.require '@rel==.t1' as '@this.t1.as.newName'
@namespace

newFunc() {
    echo "newFunc in t2";
    @this.t1.as.newName.newFunc
}
