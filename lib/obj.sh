#!/bin/bash

################################################################
# Allocates an object pointer.  Must call `Obj__init` on this
# pointer after this is called.
#
# @param $1: The class to instantiate, following the format:
#   alias.ClassName
# @returns: A pointer to the object
################################################################
Obj__alloc(){
    local class="$1"
    class=${class//\./_}
    echo "$class""_$(Obj_generate_uuid)"
}

################################################################
# Initializes the object, and calls the objects constructor
#
# @param $1: The object pointer
# @param ${@:2} Any additional parameters to be passed to
#   the objects constructor
################################################################
Obj__init(){
    # Getting the class + uuid
    local position=1
    IFS='_' read -ra segment <<< "$1"
    for part in "${segment[@]}"; do
        if [[ "$position" -eq 1 ]]; then
            local package_alias="$part"
        elif [[ "$position" -eq 2 ]]; then
            local class="$part"
        elif [[ "$position" -eq 3 ]]; then
            local uuid="$part"
        fi
        position=$((position+1))
    done

    # Getting the class directory for the package
    local class_directory="$(Obj_get_imported_directory "$package_alias")/$Ash__module_classes_folder"
    if [[ "$class_directory" = "" ]]; then
        Logger__error "Cannot create an object with the alias of $package_alias, as it has not been imported"
        exit
    fi

    # Verifying file exists
    local class_file="$class_directory/$class.sh"
    if [[ ! -f "$class_file" ]]; then
        Logger__error "There is no file named $class.sh in the aliased package"
        exit
    fi

    # Creating unique variable / method names
    local to_find="$class"_
    local to_replace="$package_alias"_"$class"_"$uuid"_
    eval "$(cat "$class_directory/$class.sh" | sed -e "s:$to_find:$to_replace:g")"

    # Calling the constructor
    Obj__call $1 construct "${@:2}"
}

################################################################
# Gets a value from an object
#
# @param $1: The object pointer
# @param $2: The variable name
# @returns: The value of the variable
################################################################
Obj__get(){
    variable="$1__$2"
    echo ${!variable}
}

################################################################
# Sets a value on an object
#
# @param $1: The object pointer
# @param $2: The variable name
# @param $3: The new value of the variable
################################################################
Obj__set(){
    variable="$1__$2"
    eval $variable="\"$3\""
}

################################################################
# Calls a public method on an object
#
# @param $1: The object pointer
# @param $2: The method name
# @param ${@:3} Any additional parameters to the method
################################################################
Obj__call(){
    # Params
    local pointer="$1"
    local method_name="$2"

    # Getting package alias
    IFS='_' read -ra segment <<< "$pointer"
    for part in "${segment[@]}"; do
        local package_alias="$part"
        break
    done

    # Swapping current context so we can self-reference in any method calls
    local old_context=$(Obj_get_imported_package "$Obj__THIS")
    local new_context=$(Obj_get_imported_package "$package_alias")
    Obj__import "$new_context" "$Obj__THIS"

    # Calling method
    "$1__$2" "${@:3}"

    # Resetting context
    Obj__import "$old_context" "$Obj__THIS"
}

################################################################
# Prints out all public member variables of an object
#
# @param $1: The object pointer
################################################################
Obj__dump(){
    echo "====== $1 ======"
    (set -o posix ; set) | grep ^$1__ | sed -e "s:$1__::g" | sed -e "s:^:| :g"
    echo "====================================="
}

##################################
# Generates a universally unique
# identifier (UUID) for an object
#
# @returns: A UUID
##################################
Obj_generate_uuid(){
    local UUID_LENGTH=16
    local count=1
    local uuid=""

    while [ "$count" -le $UUID_LENGTH ]
    do
        random_number=$RANDOM
        let "random_number %= 16"
        hexval=$(Obj_map_hex "$random_number")
        uuid="$uuid$hexval"
        let "count += 1"
    done
    echo $uuid
}

##################################
# Converts an integer to a single
# hex value
#
# @param $1: An integer from 1 to 15
# @returns: A hex value
##################################
Obj_map_hex(){
case "$1" in
0)  echo "0"
    ;;
1)  echo "1"
    ;;
2)  echo "2"
    ;;
3)  echo "3"
    ;;
4)  echo "4"
    ;;
5)  echo "5"
    ;;
6)  echo "6"
    ;;
7)  echo "7"
    ;;
8)  echo "8"
    ;;
9)  echo "9"
    ;;
10)  echo "A"
    ;;
11)  echo "B"
    ;;
12)  echo "C"
    ;;
13)  echo "D"
    ;;
14)  echo "E"
    ;;
15)  echo "F"
    ;;
*) echo ""
   ;;
esac
}
