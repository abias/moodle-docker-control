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
source moodle-docker-startup.sh -c <$clustersstring> -v <$versionsstring> [options]

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


# Verify that the script is being sourced (to be able to give the environment variables back to the calling shell)
if [[ $0 == "$BASH_SOURCE" ]]; then
    usage
    exit 1
fi

# Process parameters
while getopts 'hc:v:p:d:s:mebu' OPTION; do
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
                cluster="-c $OPTARG"
            fi
            ;;
        v)
            if ! array_contains_element "$OPTARG" "${versions[@]}"; then
                usage
                return 1
            else
                version="-v $OPTARG"
            fi
            ;;
        p)
            if ! array_contains_element "$OPTARG" "${phps[@]}"; then
                usage
                return 1
            else
                php="-p $OPTARG"
            fi
            ;;
        d)
            if ! array_contains_element "$OPTARG" "${databases[@]}"; then
                usage
                return 1
            else
                database="-d $OPTARG"
            fi
            ;;
        s)
            if ! array_contains_element "$OPTARG" "${browsers[@]}"; then
                usage
                return 1
            else
                browser="-s $OPTARG"
            fi
            ;;
        m)
            initmanual="-m"
            ;;
        e)
            initdata="-e"
            ;;
        b)
            initbehat="-b"
            ;;
        u)
            initunit="-u"
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


###################################
### run dedicated scripts
###################################

source moodle-docker-env.sh $cluster $version $php $database $browser

echo
$pathtobin up -d

if [[ -n "$initmanual" ]] || [[ -n "$initdata" ]] || [[ -n "$initbehat" ]] || [[ -n "$initunit" ]]; then
    echo
    moodle-docker-init.sh $initmanual $initdata $initbehat $initunit
fi
