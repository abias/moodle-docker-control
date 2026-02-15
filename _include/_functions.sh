#!/bin/bash

###################################
### functions
###################################

success ()
{
    echo -e "\033[32mSuccess\033[0m"
    return 0
}

failure ()
{
    echo -e "\033[31mFailed (return code: $?)\033[0m" >&2
    exit 1
}

now ()
{
    echo
    echo -e "\033[1;35mNow: $1\033[0m"
}

confirm ()
{
    read -p "Continue (y/n)? " CONT
    if [ "$CONT" != "y" ]; then
        echo "Ok, exiting...";
        exit 1;
    fi
}

ask ()
{
    read -p "Do you want me to do this (y/n)? " CONT
    if [ "$CONT" == "y" ]; then
        echo "Ok, I will do this...";
        $1 \
            && success || failure
    elif [ "$CONT" == "n" ]; then
        echo "Ok, I will not do this...";
    else
        echo "Invalid answer, exiting...";
        exit 1;
    fi
}

acknowledge ()
{
    read -p "Press any key to continue."
}

array_join_by ()
{
    local IFS="$1"
    shift
    echo "$*"
}

array_contains_element ()
{
    local e match="$1"
    shift
    for e
    do
        if [[ "$e" == "$match" ]]; then
            return 0
        fi
    done
    return 1
}

array_get_index_of()
{
    needle=$1 && shift
    haystack=("$@")
    for i in "${!haystack[@]}"; do
        if [[ "${haystack[$i]}" = "${needle}" ]]; then
            echo "${i}"
        fi
    done
}

detect_moodle_public_prefix ()
{
    # Detect if we are in Moodle 5.1+ and we use the public/ folder
    PUBLICPREFIX=""
    if [ -d "${MOODLE_DOCKER_WWWROOT}/public/admin/tool/behat" ]; then
        PUBLICPREFIX="public/"
    fi
}
