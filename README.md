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

Person_birthdays_count=0

Person__construct(){
    Person__id="$1"
    Person__name="$2"
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

### Instantiating Objects

To create an object, there are two steps.  First we have to allocate a pointer to the object, then we have to initialize the object.
