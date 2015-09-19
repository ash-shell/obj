# Ash Obj

Ash Obj is an [Ash](https://github.com/BrandonRomano/ash) module that adds object support to Bash.

## Getting started

### Ash Users

Ash Obj is part of the Ash core, so you can immediately start using it within your Ash modules.

Simply place your Classes in a directory named `classes` in the root of your modules directory, and start using them!

### Non Ash Users

Even if you're not an Ash user, this module can be used as a library.

Just include the `obj.sh` library file in your script, and also point to where you're going to be keeping your classes.

The start of your script will look something like this:

```bash
. lib/obj.sh                            # Importing Obj library
Obj__classes_directory="./classes"      # Setting classes directory
```
