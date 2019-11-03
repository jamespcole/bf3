import.require 'params>base'
params.init() {
	params.__init() {
		import.useModule 'params_base'
	}
	params.get() {
		params_base.get "$@"
	}
	params.getUntil() {
		params_base.getUntil "$@"
	}
}
