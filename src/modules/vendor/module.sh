import.require 'vendor>base'
vendor.init() {
	vendor.__init() {
		import.useModule 'vendor_base'
	}
	vendor.wrap() {
		vendor_base.wrap "$@"
	}
	vendor.getPath() {
		vendor_base.getPath "$@"
	}
}
