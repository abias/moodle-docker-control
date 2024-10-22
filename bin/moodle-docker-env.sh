#!/bin/bash

###################################
### includes
###################################

CURRENTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$CURRENTDIR/../_include/_functions.sh"
source "$CURRENTDIR/../_config/_localconfig.sh"


###################################
### unset variables
###################################

# The variables used in this script have to be unset here as the script is sourced and might have run before
unset cluster version php database browser
unset clustersstring versionsstring phpsstring databasesstring browsersstring
unset versionname instancepath instancename port2 port3 port4 port5 webport vncport


###################################
### check startup
###################################

usage ()
{
    clustersstring=`array_join_by "|" "${clusters[@]}"`
    versionsstring=`array_join_by "|" "${versions[@]}"`
    phpsstring=`array_join_by "|" "${phps[@]}"`
    databasesstring=`array_join_by "|" "${databases[@]}"`
    browsersstring=`array_join_by "|" "${browsers[@]}"`
    cat <<EOU
Usage: 
source moodle-docker-env.sh -c <$clustersstring> -v <$versionsstring> [options]

Mandatory parameters:
  -c <$clustersstring>
     The moodle instance cluster which is to be used
     Defaults to: $clusters_default
  -v <$versionsstring>
     The moodle version which is to be used
     Defaults to: $versions_default

Optional parameters:
  -p <$phpsstring>
     The PHP version which is to be used
     Defaults to: $phps_default
  -d <$databasesstring>
     The database engine which is to be used
     Defaults to: $databases_default
  -s <$browsersstring>
     The browser which is to be used for selenium testing
     Defaults to: $browsers_default
EOU
}


# Verify that the script is being sourced (to be able to give the environment variables back to the calling shell)
if [[ $0 == "$BASH_SOURCE" ]]; then
    usage
    exit 1
fi

# Process parameters
OPTIND=1 # This is needed as the script is sourced
while getopts 'hc:v:p:d:s:' OPTION; do
    case "$OPTION" in
        h)
            usage
            return 0
            ;;
        c)
            if ! array_contains_element "$OPTARG" "${clusters[@]}"; then
                usage
                return 1
            else
                cluster=$OPTARG
            fi
            ;;
        v)
            if ! array_contains_element "$OPTARG" "${versions[@]}"; then
                usage
                return 1
            else
                version=$OPTARG
            fi
            ;;
        p)
            if ! array_contains_element "$OPTARG" "${phps[@]}"; then
                usage
                return 1
            else
                php=$OPTARG
            fi
            ;;
        d)
            if ! array_contains_element "$OPTARG" "${databases[@]}"; then
                usage
                return 1
            else
                database=$OPTARG
            fi
            ;;
        s)
            if ! array_contains_element "$OPTARG" "${browsers[@]}"; then
                usage
                return 1
            else
                browser=$OPTARG
            fi
            ;;
        :)
            usage
            return 1
            ;;
        *)
            usage
            return 1
            ;;
        ?)
            usage
            return 1
            ;;
    esac
done
shift $((OPTIND-1))


# Verify that a cluster was given
if [[ -z "$cluster" ]]; then
    usage
    return 1
fi

# Verify that a version was given
if [[ -z "$version" ]]; then
    usage
    return 1
fi

# Handle specialties of the master branch
if [[ "$version" == 'master' ]]; then
    versionname=$version
else
    versionname=stable$version
fi

# If no PHP version was given, use the default
if [[ -z "$php" ]]; then
    php=$phps_default
fi

# If no database was given, use the default
if [[ -z "$database" ]]; then
    database=$databases_default
fi

# If no browser was given, use the default
if [[ -z "$browser" ]]; then
    browser=$browsers_default
fi


###################################
### compose data
###################################

# Compose the instance path
instancepath=${wwwrootbase}${versionname}_${cluster}

# Compose the instance name
instancename=${instancenamebase}${versionname}_${cluster}_${database}_php${php//.}

# Compose the instance ports
port2=$(array_get_index_of $cluster "${clusters[@]}")
port3=$(array_get_index_of $version "${versions[@]}")
port4=$(array_get_index_of $database "${databases[@]}")
port5=$(array_get_index_of $php "${phps[@]}")
webport=${webportbase}${port2}${port3}${port4}${port5}
vncport=${vncportbase}${port2}${port3}${port4}${port5}


###################################
### set environment
###################################

export COMPOSE_PROJECT_NAME=$instancename
export MOODLE_DOCKER_WWWROOT=$instancepath
export MOODLE_DOCKER_DB=$database
export MOODLE_DOCKER_PHP_VERSION=$php
export MOODLE_DOCKER_WEB_PORT=$bindto:$webport
export MOODLE_DOCKER_BROWSER=$browser
export MOODLE_DOCKER_SELENIUM_VNC_PORT=$bindto:$vncport


###################################
### change directory
###################################

cd $MOODLE_DOCKER_WWWROOT


###################################
### information
###################################

echo
echo -e "Instance name:    \033[1m${instancename}\033[0m"
echo -e "Instance path:    \033[1m${instancepath}\033[0m"
echo -e "Cluster:          \033[1m${cluster}\033[0m"
echo -e "Moodle Version:   \033[1m${version}\033[0m"
echo -e "PHP Version:      \033[1m${php}\033[0m"
echo -e "Database:         \033[1m${database}\033[0m"
echo -e "Selenium browser: \033[1m${browser}\033[0m"
echo
echo -e "Webserver URL:    \033[1m\033[93mhttp://${bindto}:${webport}/\033[39m\033[0m"
echo -e "VNC Port:         \033[1m${bindto}:${vncport}\033[0m"
