import.require '@rel==.t2' extend '@this'

@namespace

newFunc() {
    @this.super.newFunc "$@"
    echo "added in t3"
}
