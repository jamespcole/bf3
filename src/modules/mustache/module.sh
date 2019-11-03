vendor.wrap 'mo/mo' 'vendor.include.mo'

@namespace

__init() {
	vendor.include.mo
}

compile() {
	local __params
	params.get "$@"
	echo "${__params[template]}" | mo
}

__global::moIsFunction() {
    # JC - replaced function with this as the previous method
    # would become exponentially slower with the number of
    # functions in scope
    declare -f -F $1 > /dev/null
    return $?
}
