#!/bin/bash

###################################
### includes
###################################

CURRENTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$CURRENTDIR/../_include/_functions.sh"
source "$CURRENTDIR/../_config/_localconfig.sh"


###################################
### check startup
###################################

usage ()
{
    cat <<EOU
Usage: 
moodle-docker-init.sh [options]

Parameters (at least one is required):
  -m
     Initialize the database for manual usage
  -e
     Initialize the data set with example courses and test users
  -b
     Initialize the behat testing environment
  -u
     Initialize the PHPUnit testing environment
EOU
}


# Verify that the script is not being sourced (just in case that the user was confused)
if [[ $0 != "$BASH_SOURCE" ]]; then
    usage
    return 1
fi


# Verify that all necessary env variables are set
if [[ -z "$COMPOSE_PROJECT_NAME" ]] || [[ -z "$MOODLE_DOCKER_WWWROOT" ]] || [[ -z "$MOODLE_DOCKER_DB" ]] || [[ -z "$MOODLE_DOCKER_PHP_VERSION" ]] || [[ -z "$MOODLE_DOCKER_WEB_PORT" ]] || [[ -z "$MOODLE_DOCKER_BROWSER" ]] || [[ -z "$MOODLE_DOCKER_SELENIUM_VNC_PORT" ]] || [[ -z "$MOODLE_DOCKER_DB_PORT" ]]; then
    echo 'Necessary env variables are not set yet.'
    echo 'Please run moodle-docker-env.sh first'
    exit 1
fi


# Process parameters
while getopts 'hmebu' OPTION; do
    case "$OPTION" in
        h)
            usage
            exit 0
            ;;
        m)
            initmanual=true
            ;;
        e)
            initdata=true
            ;;
        b)
            initbehat=true
            ;;
        u)
            initunit=true
            ;;
        :)
            usage
            exit 1
            ;;
        *)
            usage
            exit 1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Verify that at least one argument was given
if [[ $OPTIND -eq 1 ]]; then
    usage
    exit 1
fi


###################################
### action
###################################

# If requested, initialize the database for manual usage
if [[ $initmanual == 'true' ]]; then
    $pathtobin exec webserver php admin/cli/install_database.php --agree-license --fullname="$COMPOSE_PROJECT_NAME" --shortname="$COMPOSE_PROJECT_NAME" --adminpass="test" --adminemail="admin@example.com"
fi

# If requested, initialize the smart data set with example courses and test users
if [[ $initdata == 'true' ]]; then
    wget https://raw.githubusercontent.com/andrewnicols/moodle-datagenerator/master/smartdata.php -P $MOODLE_DOCKER_WWWROOT/
    $pathtobin exec webserver php smartdata.php --admin
    rm -f $MOODLE_DOCKER_WWWROOT/smartdata.php
fi

# If requested, initialize the behat testing environment
if [[ $initbehat == 'true' ]]; then
    $pathtobin exec webserver php admin/tool/behat/cli/init.php
fi

# If requested, initialize the PHPUnit testing environment
if [[ $initunit == 'true' ]]; then
    $pathtobin exec webserver php admin/tool/phpunit/cli/init.php
fi


###################################
### information
###################################


echo

if [[ $initmanual == 'true' ]]; then
    echo -e "Init manual:      \033[1m\033[92mYes\033[39m\033[0m"
else
    echo -e "Init manual:      \033[1m\033[91mNo\033[39m\033[0m"
fi

if [[ $initdata == 'true' ]]; then
    echo -e "Init data:        \033[1m\033[92mYes\033[39m\033[0m"
else
    echo -e "Init data:        \033[1m\033[91mNo\033[39m\033[0m"
fi

if [[ $initbehat == 'true' ]]; then
    echo -e "Init behat:       \033[1m\033[92mYes\033[39m\033[0m"
else
    echo -e "Init behat:       \033[1m\033[91mNo\033[39m\033[0m"
fi

if [[ $initunit == 'true' ]]; then
    echo -e "Init PHPUnit:     \033[1m\033[92mYes\033[39m\033[0m"
else
    echo -e "Init PHPUnit:     \033[1m\033[91mNo\033[39m\033[0m"
fi
