import.require 'string'

vendor_base.init() {
	# vendor_base.__init() {
	# 	import.useModule 'string'
	# }
	vendor_base.wrap() {
		local __file_path="$1"
		local __wrap_function="$2"

		local __test_path
		local __vendor_path_var
		local __wrapped_function
		for __vendor_path_var in "${__import_PATHS[@]}"
		do
			__test_path="${__vendor_path_var}/vendor/${__file_path}"
			if [ -f "$__test_path" ]; then
				__wrapped_function="${__wrap_function}() {\n$(cat ${__test_path})\n}"
				eval "$(echo -e "${__wrapped_function}")"
				break;
			fi
		done
	}
	vendor_base.getPath() {
		local __return_path=$1
		local __file_path="$2"

		local __test_path
		local __vendor_path_var
		for __vendor_path_var in "${__import_PATHS[@]}"
		do
			__test_path="${__vendor_path_var}/vendor/${__file_path}"
			if [ -f "$__test_path" ]; then
				string.return_value "$__test_path" $__return_path
				break;
			fi
		done
	}

}
