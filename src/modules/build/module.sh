resource.relative '@rel==templates/init_functions.sh' into '@this'

@namespace

getInitFunctions() {
    @this.resource.get 'templates/init_functions.sh'
}
