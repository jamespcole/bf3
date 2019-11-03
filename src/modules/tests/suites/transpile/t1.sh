@namespace

newFunc() {
    echo "newFunc in t1";
}

__global::globalFunc() {
    echo "globalFunc in t1";
}

precachedFunc::precache() {
    echo "precachedFunc in t1";
}
