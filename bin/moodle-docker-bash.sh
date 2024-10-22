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
moodle-docker-bash.sh
EOU
}


# Verify that the script is not being sourced (just in case that the user was confused)
if [[ $0 != "$BASH_SOURCE" ]]; then
    usage
    return 1
fi


# Verify that all necessary env variables are set
if [[ -z "$COMPOSE_PROJECT_NAME" ]] || [[ -z "$MOODLE_DOCKER_WWWROOT" ]] || [[ -z "$MOODLE_DOCKER_DB" ]] || [[ -z "$MOODLE_DOCKER_PHP_VERSION" ]] || [[ -z "$MOODLE_DOCKER_WEB_PORT" ]] || [[ -z "$MOODLE_DOCKER_BROWSER" ]] || [[ -z "$MOODLE_DOCKER_SELENIUM_VNC_PORT" ]]; then
    echo 'Necessary env variables are not set yet.'
    echo 'Please run moodle-docker-env.sh first'
    exit 1
fi


# Process parameters
while getopts 'h' OPTION; do
    case "$OPTION" in
        h)
            usage
            exit 0
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

# Verify that no argument was given
if [[ $OPTIND -ne 1 ]]; then
    usage
    exit 1
fi


###################################
### action
###################################

$pathtobin exec webserver bash