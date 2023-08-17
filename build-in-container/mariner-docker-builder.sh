#! /bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -e

help() {
    echo "------------ Mariner Build-in-Container ------------"
    echo "
    The mariner-docker-builder.sh script presents these options
    -t                        creates container image
    -b                        creates container,
                              builds specs under [mariner_dir]/SPECS/,
                              & places output under [mariner_dir]/out/
                              (default: $mariner_dir/{SPECS,out})
    -i                        creates an interactive Mariner build container
    -c                        cleans up Mariner workspace at [mariner_dir], container images and instances
                              (default: $mariner_dir)
    --help                    shows help on usage

    Optional arguments:
    --mariner_dir             directory to use for Mariner artifacts (SPECS, toolkit, ..). Default is the current directory
    --RPM_repo_file           Path(s) to custom repo file(s) (must end in .repo). Provide multiple filepaths with space (" ") as delimiter.
    --RPM_container_URL       URL(s) of Azure blob storage container(s) to install RPMs from. Provide multiple URLs with space (" ") as delimiter.
    --disable_mariner_repo    Disable default setting to use default Mariner package repos on packages.microsoft.com

    * unless provided, mariner_dir defaults to the current directory
                        (default: $mariner_dir)
    "
    echo "----------------------------------------------------"
}

create_container() {
    echo "Creating Container Image"
    source ${tool_dir}/create-container.sh
}

run_container() {
    echo "*** Mariner artifacts will be used from $mariner_dir ***"
    if [[ "${container_type}" == "build" ]]; then
        echo "Creating Mariner Build Container and building Mariner SPECS"
    else
        echo "Creating Interactive Mariner Build Container"
    fi
    source ${tool_dir}/run-container.sh
}

cleanup() {
    echo "Cleaning up mariner artifacts at $mariner_dir ....."
    echo "This requires running as root ...."
    sudo rm -rf ${mariner_dir}/build ${mariner_dir}/ccache ${mariner_dir}/logs ${mariner_dir}/out ${mariner_dir}/toolkit
    # remove Mariner docker containers
    docker rm -f $(docker ps -aq --filter ancestor="mcr.microsoft.com/mariner-container-build:2.0")
    # remove Mariner docker images
    docker rmi -f $(docker images -aq --filter reference="mcr.microsoft.com/mariner-container-build")
}

copy_custom_repo_file() {
    RPM_repo_file=
    mkdir -p $tool_dir/scripts/custom_repos
    for repo_file in $(echo $1 | tr " " "\n")
    do
        repo_file_name=${repo_file##*/} # remove prefix ending in '/'
        cp $(realpath $repo_file) $tool_dir/scripts/custom_repos/$repo_file_name # copy repo_file inside container
        RPM_repo_file+="/mariner/scripts/custom_repos/$repo_file_name,"
    done
}

validate_custom_repo_file() {
    for repo_file in $(echo $1 | tr " " "\n")
    do
        # exit if $repo_file doesn't exist
        echo "repo_file is $repo_file"
        if [[ ! -f $(realpath $repo_file) ]]; then
            echo -e "-------- \033[31m ALERT: $repo_file doesn't exist. Exiting\033[0m --------"
            exit
        fi
        # exit if $repo_file doesn't end in '.repo'
        if [[ $repo_file != *.repo ]]; then
            echo -e "-------- \033[31m ALERT:$repo_file name must end in '.repo'. Exiting\033[0m --------"
            exit
        fi
    done
}

tool_dir=$( realpath "$(dirname "$0")" )
mariner_dir=$(realpath "$(pwd)")
disable_mariner_repo=false
enable_custom_repofile=false
enable_custom_repo_storage=false

if [ "$#" -eq 0 ]
then
    help >&2
    exit 1
fi

while (( "$#")); do
  case "$1" in
    -t ) create_container; exit 0 ;;
    -b ) container_type="build"; shift ;;
    -i ) container_type="interactive"; shift ;;
    -c ) cleanup; exit 0 ;;
    --mariner_dir ) mariner_dir="$(realpath $2)"; shift 2 ;;
    --RPM_repo_file ) enable_custom_repofile=true; validate_custom_repo_file "$2"; copy_custom_repo_file "$2"; shift 2 ;;
    --RPM_container_URL ) enable_custom_repo_storage=true; RPM_container_URL=$(echo $2 | tr " " ","); shift 2 ;;
    --disable_mariner_repo ) disable_mariner_repo=true; shift ;;
    --help ) help; exit 0 ;;
    ?* ) echo -e "ERROR: INVALID OPTION.\n\n"; help; exit 1 ;;
  esac
done

run_container
