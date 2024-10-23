#!/bin/bash

###################################
### local config: moodle-docker
###################################

# Path to moodle-docker-compose
# The path where the moodle-docker-compose script is located
pathtobin="$HOME/Workspaces/moodle-docker/bin/moodle-docker-compose"


###################################
### local config: clusters
###################################

# Clusters:
# The moodle instance clusters which should be supported for on-demand usage
clusters=(core plugins)


###################################
### local config: versions
###################################

# Versions:
# The moodle versions which should be supported for on-demand usage
versions=(master 401 402 403 404 405)


###################################
### local config: php
###################################

# PHP versions:
# The PHP versions which should be supported for on-demand usage
phps=(7.4 8.0 8.1 8.2 8.3)

# Default PHP version:
# The PHP version which is used if the parameter is not given when the script is run
phps_default='8.2'


###################################
### local config: databases
###################################

# Databases:
# The databases engines which should be supported for on-demand usage
databases=(pgsql mariadb mysql mssql oracle)

# Default database:
# The database engine which is used if the parameter is not given when the script is run
databases_default='pgsql'


###################################
### local config: browsers
###################################

# Browsers:
# The browsers for selenium testing which should be supported for on-demand usage
browsers=(firefox chrome)

# Default browser:
# The browser for selenium testing which is used if the parameter is not given when the script is run
browsers_default='firefox'


###################################
### local config: wwwroot
###################################

# WWWroot base:
# The base path which will be used for building the particular instance's wwwroot
wwwrootbase="$HOME/Workspaces/moodle-sites/moodle-docker-"


###################################
### local config: instances
###################################

# Instance name base:
# The prefix which will be used for building the instance's name
instancenamebase='moodle-docker-'


###################################
### local config: hosts and ports
###################################

# Host:
# The host which the container should bind its ports to
bindto='127.0.0.1'

# Webserver port base:
# The first digit of the port which the webserver container should bind its port to
webportbase='6'

# VNC port base:
# The first digit of the port which the selenium VNC container should bind its port to
vncportbase='5'

# DB port base:
# The first digit of the port which the DB container should bind its port to
dbportbase='4'

