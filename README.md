# BF3

BF3 is a framework for making working with bash scripts a little more organised.
It is loosely inspired by webpack(and a few other things) and adds a bunch of features to help write bash scripts, including:
* namespacing
* an import system for dependencies
* flexible and easy to use argument parsing and validation
* the ability to compile a script and its dependencies into a single file
* embed files and templates required by you script into the compiled output
* a basic transpiler that adds some syntactic sugar to your scripts
* the ability to create and combine bf3 environments from multiple sources
* mustache templating(provided by the "mo" script)

## The Structure

### Namespaces
Namespaces are used to import modules into your scripts.  A module's namespace is defined by its path from the root of the `modules` directory(using '.' as delimiters between path segments).  By convention you place your script in a file called `module.sh` inside the module's directory.

For example, if you added a new module like this:
```
modules
    | mymodules
        |examples
            | example1
                | module.sh
            | example2
                | module.sh
```

Now from other scripts you can import your new module by adding this to the top of the file.

```bash
import.require 'mymodules.examples.example1'
```

The functions in your module are now available inside the script that imported the namespace.

#### A more complete example
Lets expand on the example above to give you a more complete idea of how it works.

This is what the `example1/module.sh` file contains:
```bash

@namespace

helloWorld() {
    echo "Hello World!"
}

```

Now lets add another `example2/module.sh` which will import our example1 module.

This is what the `example2/module.sh` file contains:
```bash
import.require 'mymodules.examples.example1'

@namespace

hatWobble() {
    mymodules.examples.example1.helloWorld
}

```

NOTE: Notice the `@namespace` keyword in the above scripts.  This is not standard bash and is used to tell the transpiler that the functions in the module should be namespaced automatically.  It is still possible to create modules without using the `@namespace` keyword if you wish to(discussed in the advanced section).


## Imports

### Import

```bash
import.require 'example.module.foo'
```

### Import 'as'

```bash
import.require 'example.module.foo' as '@this.bar'
```

The 'as' import lets you alias a namespace within your script.  Lets expand on the example above to demonstrate how to use it.  Aliasing a namespace can have global effects unless you use the '@this' keyword, there are valid use cases where you might want do this but be careful when aliasing without using '@this'.

The `example2/module.sh` file has been updated with so that it uses the 'as' keyword when importing example1(without the `@this` keyword):
```bash
import.require 'mymodules.examples.example1' as 'printer'

@namespace

hatWobble() {
    printer.helloWorld
}

```

The `example2/module.sh` file has been updated with so that it uses the 'as' keyword when importing example1 and uses the `@this` keyword:
```bash
import.require 'mymodules.examples.example1' as '@this.printer'

@namespace

hatWobble() {
    @this.printer.helloWorld
}

```

NOTE: the use of `@this` means the imported namespace has an alias that is unique to the module importing it which means you are not affecting the global scope(or potentially overwriting another namespace with the same name/alias).

### Import 'mixin'

```bash
import.require 'mymodules.examples.example1' mixin '@this'
```

The `mixin` import allows you to combine modules together.

The `example2/module.sh` file has been updated with so that it uses the 'mixin' keyword when importing example1.  This will essentially copy all of example1's functions and add them to example2.  Note how we are calling the `helloWorld` function as if it was part of the example2 module using `@this.helloWorld`:
```bash
import.require 'mymodules.examples.example1' mixin '@this'

@namespace

hatWobble() {
    @this.helloWorld
}

```

You can use multiple `mixin` imports to add functions from multiple namespaces.  NOTE: if using multiple `mixin` imports and there is an identically named function in the mixed in namespaces the function from the namespace imported last will be used.

## Resources

```bash
resource.relative '@rel==templates/example.conf' into '@this'
```

Example:

```bash
resource.relative '@rel==templates/example.conf' into '@this'

@namespace

writeToFile() {
    echo "$(@this.resource.get 'templates/example.conf')" >> /tmp/example_file.conf
}

```

Example with Template

module.sh
```bash
resource.relative '@rel==templates/example.template.conf' into '@this'

@namespace

writeToFile() {
    local -A templateData
    templateData[someTemplateVariable]='foo'
    templateData[anotherTemplateVariable]='bar'
    mustache.compile \
        --template "$(@this.resource.get 'templates/example.template.conf')"
}

```

templates/example.template.conf
```
# This is an arbitrary example config file with mustache variables
hostname: {{templateData.someTemplateVariable}}
port: {{templateData.anotherTemplateVariable}}
```

## Module Variables
A module can also contain variables which are scoped to that particular namespace.  It is important to note that when you alias a namespace a copy of the variables are created that are scoped to the _alias_.

NOTE: when using `mixin` imports module variables are also included in the mixin.  In the case where multiple mixins use the same variable name or assign values to the same variable the last imported mixin will be used.

Here is an updated version of `example1/module.sh` with a module variable called `suffix` added:
```bash

@namespace

@this[suffix]='!'

helloWorld() {
    echo "Hello World@this[suffix]"
}

```

And here is an updated The `example2/module.sh` that sets example1's suffix variable to a new value and also demonstrates accessing another modules's variables.

```bash
import.require 'mymodules.examples.example1' as '@this.printer'

@namespace

__init() {
    @set->@this.printer[suffix]='!!!'
}

hatWobble() {
    @this.printer.helloWorld
    echo "Accessing the example1 module variable value @get->@this.printer['suffix']"
}

```

## Creating Commands

In BF3 commands are simply a module which also contains a `main()` function.

And here is an updated The `example2/module.sh` with a main function added so we can use it as a command.

```bash
import.require 'mymodules.examples.example1' as '@this.printer'

@namespace

__init() {
    @set->@this.printer[suffix]='!!!'
}

hatWobble() {
    @this.printer.helloWorld
    echo "Accessing the example1 module variable value @get->@this.printer['suffix']"
}

main() {
    @this.hatWobble
}

```

### Running a Command

There are two ways to run a command, either by compiling it first(covered later) or by compiling it on the fly with the `bf3 --run` command(useful when developing and debugging).

To run our `example2` module as a command we can simply run the following:

```
bf3 --run 'mymodules.examples.example2'
```

### Adding Arguments to a Command

BF3 provides a useful argument parser and validator with some advanced features such as dependencies or exclusions between arguments.  The example below is a very basic usage of the BF3 arguments, the advanced features are discussed later in this document.

Here is another version of  `example2/module.sh` which has been updated to add a command line argument.

```bash
import.require 'mymodules.examples.example1' as '@this.printer'

@namespace

__init() {
    @set->@this.printer[suffix]='!!!'
}

hatWobble() {
    @this.printer.helloWorld
    echo "Accessing the example1 module variable value @get->@this.printer['suffix']"
}

main::args() {
    parameters.add --key 'suffix' \
        --namespace '@this.main' \
        --name 'Message Suffix' \
        --alias '--suffix' \
        --alias '-s' \
        --desc 'Specify the suffix for the message.' \
        --default '!!!' \
        --has-value 'y'
}

main() {
    @=>params
    @set->@this.printer[suffix]="@params[suffix]"
    @this.hatWobble
}
```

We can now run the command and specify the `suffix` argument, eg:

```bash
bf3 --run 'mymodules.examples.example2' --suffix '@@@'
```

You can also try running:
```bash
bf3 --run 'mymodules.examples.example2' --help
```
The information about the new `suffix` argument will automatically be displayed.


## Building/Compiling a Command

Another useful feature of BF3 is the ability to build/compile a command into a single file with all the dependencies and resources included.  This can be very useful when you need to distribute scripts to someone else as you can just send them a single completely self contained script file.

To build our `example2` module into a command called `hello-world` we can run the following:
```bash
bf3 --build 'mymodules.examples.example2' --build-name hello-world
```

You can now run the compiled script using:
```bash
hello-world --suffix '@@@'
```

The compiled script file will be located in the `install_hooks` directory of you current active BF3 environment.

## Managing BF3 Environments

BF3 implements the concept of environments(kind of inspired by python venv).  BF3 environments make it easy to add modules from sources like git or isolate your project specific scripts from the BF3 core.  BF3 environments can be "stacked" meaning that you can combine modules from multiple sources in a single environment.

The following example shows how to create a new environment:

```bash
bf3_env --create myenv
```

This command will create the directory structure and base files for you new environment in the directory passed to the `--create` argument.  The structure of the environment looks like this:

```
env
    | activate.sh
    | add.sh
    | libs.sh
modules
install_hooks
```
Now to use this new environment we can do one of two things, either "add" it to the current environment or "activate" it making it the current active environment.  While "add" and "activate" are similar there are important differences:

* add should be used by other environments(often from that environment's `activate.sh` file) that might depend on modules in your environment
* activate sets up your environment and may include adding other environments

The majority of the time you will probably just want to activate your environment with the command:

```bash
. myenv/env/activate.sh
```

TIP: if you want your BF3 environment activated by default when you log in you can add your activation command to the end of your .bashrc file.

Once you have activated you environment you can view the configuration of the active environment by running the command:

```bash
bf3_env --info
```

### Adding Module Libraries to your Environment

To add additional module libraries to your environment edit the `env/libs.sh` file.

For example to add the provisioning modules library to your environment you first need to clone it from git and then add its location to your `env/libs.sh` file.

```bash
cd module_libs
git clone https://github.com/jamespcole/bf3-provision.git
```

 Then append the following to your environment's `env/libs.sh` file:

```bash
source "${BF3_ACTIVE_PATH}/module_libs/bf3-provision/src/env/add.sh"
```

Then reactivate your environment:

```bash
source "${BF3_ACTIVE_PATH}/env/activate.sh"
```

You can now import the modules from `bf3-provision` library for use your modules.


## Installation and Setup

Pull the latest BF3 core from git:

```bash
git clone git@github.com:jamespcole/bf3.git
. bf3/src/env/activate.sh
```

Then create a BF3 environment for your custom modules:

```bash
bf3_env --create /some/path
. /some/path/env/activate.sh
```

 You can now start creating your own modules inside the `modules` directory which is added automatically when a new environment is created.

 If you want your environment to be automatically activated on login add the activation command to the end of your `.bashrc` file, eg:

```bash
. /some/path/env/activate.sh > /dev/null
```
