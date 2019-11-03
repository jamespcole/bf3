
* [string.init()](#stringinit)
* [string.return_value()](#stringreturn_value)


## string.init()

The string namespace provides common string functions and
utilties

#### Example

```bash
   import.require 'string'

```

#### See also

* [string.return_value()](#string.return_value())

## string.return_value()

A helper for returning string from a function and working
around bash's string scoping.  It will populate the var passed as the
first parameter(which is in the caller's scope) with the value from the
second one(which is in local scope)

#### Example

```bash
   callingFunction() {
		local __my_str
		calledFunction __my_str 'some other param'
		echo "${__my_str}"
	}
   calledFunction() {
		local __return_var=$1
		local __other_param="$2"

		local __a_new_var='created in this function'
		string.return_value "$__a_new_var" $__return_var
	}

```

### Arguments

* **$1** (The): return variable that will be populated after the call
* **$2** (The): value that will be returned
