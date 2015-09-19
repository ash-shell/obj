# Ash Obj

Ash Obj is an [Ash](https://github.com/BrandonRomano/ash) module that adds object support to Bash.

# Getting started

## Ash Users

Ash Obj is part of the Ash core, so you can immediately start using it within your Ash modules.

Simply place your Classes in a directory named `classes` in the root of your modules directory, and start using them!

For an example of an ash module that uses objects, [look here](https://github.com/BrandonRomano/ash-obj-examples).

## Non Ash Users

Even if you're not an Ash user, this module can be used as a library.

Just include the `obj.sh` library file in your script, and also point to where you're going to be keeping your classes.

The start of your script will look something like this:

```bash
. lib/obj.sh                            # Importing Obj library
Obj__classes_directory="./classes"      # Setting classes directory
```

# Features + Usage

## Creating Classes

Before getting into any details, as you would expect classes are the definition of what an object is.

Classes must be placed in the directory defined to hold classes (for Ash users, this is in a directory named `classes` in the root of your module).  Classes also must be named as their classname with `.sh` as their extension.  By convention, you should use [PascalCase](http://c2.com/cgi/wiki?PascalCase) for class naming as many modern programming languages use.

> For example, if I were to create a class that would define what a Person object is, I would name the file `Person.sh`.

I'll explain the different components of what a class is below, but here is what a class looks like.  This would be in a file named Person.sh in our classes diretory:

> For a fully commented version of this class, look [here](https://github.com/BrandonRomano/ash-obj-examples/blob/master/classes/Person.sh)

```bash
#!/bin/bash
# This is a simple class that represents a Person.

Person__id=""
Person__name=""
Person__age=""

Person_birthdays_count=0

Person__construct(){
    Person__id="$1"
    Person__name="$2"
    Person__age="$3"
}

Person__make_older(){
    Person__age=$((Person__age+1))
    Person_update_birthday_count
}

Person_update_birthday_count(){
    Person_birthdays_count=$((Person_birthdays_count+1))
    echo "Happy Birthday $Person__name!"
    echo "This is birthday #$Person_birthdays_count we have celebrated with $Person__name."; echo
}
```

### Public Members

Public members are variables that are bound to an object, that may be both fetched and updated from outside the scope of the class.

A public member is denoted by the Class name followed by two underscores `__`.

> Following our example above, `Person__id` is a public member.

### Private Members

Private members are variables that are bound to an object, but may not be accessed from outside the scope of the class.  These are very powerful, as they allow you to manage state within an object without exposing additional information.

A private member is denoted by the Class name followed by a single underscore `_`.

> Following our example above, `Person_birthdays_count` is a private member.

### Public Methods

Public methods are functions bound within an object that have access to all of the public/private members.  Public methods also have access to all other public/private methods.  Public methods may be called from outside of the scope of the object.

A public method is a function denoted by the Class name followed by two underscores `__`.

> Following our example above, `Person__make_older` is a public method.

### Private Methods

Private methods are functions bound within an object that have access to all of the public/private members. Private methods also have access to all other public/private methods.  Private methods may *not* be called from outside of the scope of the object, and are to only be used internally.

A private method is a function denoted by the Class name followed by a single underscore `_`.

> Following our example above, `Person_update_birthday_count` is a private method.

### Constructors

Constructors are magically named funcitons that get called when an object is initialized.  Constructors can take an arbitrary amount of parameters, and have all of the same powers as a public method (as it technically is a public method).

A constructor is a function denoted by the class name followed by `__construct`.

> Following our example above, `Person__construct` is our constructor.

## Creating and Using Objects

Now that we've created this cool class, I'd imagine now we would want to use it.

### Objects by Reference

It's worth noting that all objects created will be by reference (or by means of pointer).

This makes this library work extremely well with bash, as these pointers are just strings that can be dealt with in any way that bash currently supports.  This allows you to throw objects into arrays, use them as parameters to functions, use them in subshells, etc, all without any additional extension to Bash.

### Instantiating Objects (Obj__alloc / Obj__init)

To create an object, there are two steps.  First we have to allocate a pointer for the object, then we have to initialize the object.

To allocate a pointer for an object, we must use `Obj__alloc`, which is passed a class name.  Object alloc will return the pointer you will use to refer to the object, so hold onto this!

To initialize an object, we must use `Obj__init`, which is passed the object pointer.  You may pass any additional parameters after this, and they will get passed along to the objects construct method.

For example, if I wanted to create a new person object that represents myself, I would do this:

```bash
brandon=$(Obj__alloc "Person")
Obj__init $brandon 1 "Brandon" 23
```

Now I have a reference to `$brandon`, which is a pointer to a initialized object representing myself.

##### A quick Obj__init Gotcha

It's worth nothing that if you use `Obj__init` within a subshell, the object will only be initialized within the scope of that subshell.  Your best bet is to not wrap this call in a subshell unless you really know what you're doing.  However, we are allowed to pass objects into subshells after they have been initialized.  This follows the same rules as variables in a subshell:

> Variables in a subshell are not visible outside the block of code in the subshell. They are not accessible to the parent process, to the shell that launched the subshell. These are, in effect, variables local to the child process. - [tldp.org](http://www.tldp.org/LDP/abs/html/subshells.html)

### Object Dump for Debugging (Obj__dump)

It's very useful to find out the state of a current object when trying to debug a script.

If I were to run `Obj__dump $brandon`, immediately after initializing the object in the last section, it would output:

```
====== Person_4D69741E8CB76419 ======
| age=23
| id=3
| name='Brandon Romano'
=====================================
```

As you can see, `Obj__dump` prints out all of the public variables in an object.

### Setters + Getters

As mentioned in previous sections, public members can be accessed / updated.

#### Updating Member Variables (Obj__set)

To update a public member belonging to an object, you can use `Obj__set`.

There are three parameters to `Obj__set`.

The first is the object pointer itself that was returned by `Obj__alloc`.

The second is the name of the public member variable.  This does not include the in-class `ClassName__` prefix.  If in your class you had a member `Person__name`, you would simply pass `name`.

The third is the new value you would like to set to that member variable.

```bash
Obj__set $brandon name "Brandon Romano"
```

An `Obj__dump` on our `$brandon` object would now yield:

```
====== Person_4D69741E8CB76419 ======
| age=23
| id=3
| name='Brandon Romano'
=====================================
```

#### Accessing Member Variables (Obj__get)

To get the value of a public member belonging to an object, you can use `Obj__get`.

There are two parameters to `Obj__get`.

The first is the object pointer itself that was returned by `Obj__alloc`.

The second is the variable name, following the same rules as discussed in the previous section.

If I were to now run:

```bash
myname=$(Obj__get $brandon name)
echo $myname
```

It would output:

```
Brandon Romano
```

### Calling Public Methods

Inside of a class, methods are called with the full name of the function (e.g. `Person__make_older`).

Outside of the class, this is different, and public methods must be called via `Obj__call`.

There are two required parameters to `Obj__call`.

The first is the object pointer itself that was returned by `Obj__alloc`.

The second is the method name. This does not include the in-class `ClassName__` prefix.  If in your class you had a public method `Person__make_older`, you would simply pass `make_older`.

Following our example, we could call:

```
Obj__call $brandon make_older
```

If you wanted to pass any parameters to the actual function inside of the class, this is possible.  You are able to pass any number of parameters to `Obj__call` after the second parameter, and they will be packed up as parameters to the `make_older` method.

Hypothetically, if make_older allowed a single parameter ($1) to specify how many years older, you could call:

```
Obj__call $brandon make_older 2
```
