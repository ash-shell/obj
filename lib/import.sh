#!/bin/bash

# Imports map
Obj_imports=( )

################################################################
# Imports a package
#
# @param $1: The module to import
# @param $2: The alias of the module
################################################################
Obj__import() {
    # Params
    local import_module="$1"
    local module_alias="$2"

    # Checking if package path exists
    local package_path=$(Ash__find_module_directory "$import_module" 0)
    if [[ "$package_path" = "" ]]; then
        Logger__error "Cannot import $import_module, no module with that package is installed"
        exit
    fi

    # Verifying there is an alias
    if [[ "$module_alias" = "" ]]; then
        Logger__error "Cannot import without an alias"
        exit
    fi

    # Checking if the alias already exists
    local import=""
    local pos=0
    for import in "${Obj_imports[@]}" ; do
        local key=${import%%:*}
        local value=${import#*:}
        if [[ "$key" = "$module_alias" ]]; then
            # Replace it
            Obj_imports[$pos]="$module_alias:$package_path"
            return
        fi
        pos=$((pos+1))
    done

    # Appending to imports
    Obj_imports+=("$module_alias:$package_path")
}

################################################################
# Gets the import directory from the alias
#
# @param $1: The alias of an import
# @returns: The directory of the module
################################################################
Obj_get_imported_directory() {
    local import=""
    for import in "${Obj_imports[@]}" ; do
        local key=${import%%:*}
        local value=${import#*:}
        if [[ "$key" = "$1" ]]; then
            echo "$value"
            return
        fi
    done
}
