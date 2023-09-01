#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -e
set -x

# arguments:
#
# --container_type             : container type is either 'build' or 'interactive'
# --RPM_repo_file              : space delimited path(s) to custom repo file(s)
# --RPM_container_URL          : space delimited URL(s) to Azure container(s) with RPMs
# --enable_custom_repofile     : enable installing RPMs from repo(s) listed in RPM_repo_file, if true
# --enable_custom_repo_storage : enable installing RPMs from container(s) in RPM_container_URL, if true
# --disable_mariner_repo       : disable installing RPMs from default Mariner PMC, if true
#

# parse args passed to container
while (( "$#" )); do
    case "$1" in
        --container_type)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            container_type=$2
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
        --RPM_repo_file)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            RPM_repo_file=$2
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
        --RPM_container_URL)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            RPM_container_URL=$2
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
        --enable_custom_repofile)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            enable_custom_repofile=$2
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
        --enable_custom_repo_storage)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            enable_custom_repo_storage=$2
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
        --disable_mariner_repo)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            disable_mariner_repo=$2
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
        -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;
        *) # unsupported argument
        echo "Error: Unsupported argument $1" >&2
        exit 1
        ;;
    esac
done

source /mariner/scripts/setup.sh

if [[ "${container_type}" == "build" ]]; then
    # exit if SPECS/ is empty && container_type is build as there is nothing to be done
    if [ ! "$(ls -A $SPECS_DIR)" ]; then
        echo -e "-------- \033[31m ALERT: Exiting the build container. No specs found in SPECS which is mounted at \$mariner_dir/SPECS on the host\033[0m --------"
        exit 1
    fi
    source /mariner/scripts/build.sh
else
    /bin/bash
fi
