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
moodle-docker-xdebug.sh [action]

Actions (exactly one is required):
  -i
     Initialize XDebug in the webserver container
  -e
     Enable XDebug in the webserver container
  -d
     Disable XDebug in the webserver container
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
while getopts 'hied' OPTION; do
    case "$OPTION" in
        h)
            usage
            exit 0
            ;;
        i)
            initxdebug=true
            ;;
        e)
            enable=true
            ;;
        d)
            disable=true
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

# Verify that exactly one argument was given
if [[ $OPTIND -ne 2 ]]; then
    usage
    exit 1
fi

if [[ $initxdebug == 'true' ]]; then
    echo 'This will add XDebug to the webserver container!'
    echo 'It will be added in a disabled way and will have to be enabled in a second step.'
    confirm
fi


###################################
### action
###################################

# If requested, initialize XDebug in the webserver container
if [[ $initxdebug == 'true' ]]; then
    $pathtobin exec webserver pecl install xdebug
    $pathtobin exec webserver docker-php-ext-enable xdebug.so

    read -r -d '' conf <<'EOF'

; Settings for Xdebug Docker configuration
xdebug.mode = debug
xdebug.start_with_request = yes
xdebug.client_host = host.docker.internal
EOF

    $pathtobin exec webserver bash -c "echo '$conf' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
fi

# If requested or if initializing, disable XDebug in the webserver container
if [[ $disable == 'true' ]] || [[ $initxdebug == 'true' ]]; then
    $pathtobin exec webserver sed -i 's/^zend_extension=/; zend_extension=/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    $pathtobin restart webserver
fi

# If requested, enable XDebug in the webserver container
if [[ $enable == 'true' ]]; then
    $pathtobin exec webserver sed -i 's/^; zend_extension=/zend_extension=/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    $pathtobin restart webserver
fi
