#!/bin/bash

# get our arguments
POSITIONAL=()
COMMANDS=()
os="$(uname -s)"
if [ ${os} = "Linux" ]; then
    echo "Linux OS detected"
    SCRIPT_DIR=$(dirname $(readlink -f $0))
elif [ ${os} = "Darwin" ]; then
    echo "MacOS detected"
    SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
fi
ROOT_DIR=$(realpath "${SCRIPT_DIR}/..")

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --build)
        COMMANDS+="docker-compose build --no-cache"
        shift # past argument
        ;;
        -c|--command)
        shift # past argument
        SHELL_COMMAND=$1
        shift # past argument
        ;;
        --debug)
        DEBUG=true
        shift # past argument
        ;;

        *) # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# check we have the required .env file otherwise create them from the template
if [[ ! -f "${SCRIPT_DIR}/.env" ]]; then
    cp "${SCRIPT_DIR}/.env.template" "${SCRIPT_DIR}/.env"
fi

# read the .env file
DOCKER_ENV=()
DOCKER_ENV+=$(grep -v '^#' "${SCRIPT_DIR}/.env" | xargs)
# add them to this script too
export $(grep -v '^#' "${SCRIPT_DIR}/.env" | xargs)

# if we have no command (like for instance passed by the CI) just run zsh
if [ -z "${SHELL_COMMAND}" ]; then
    echo "No command passed";
    COMMANDS+=("cd \"${SCRIPT_DIR}\" && HOST_PATH=\"${ROOT_DIR}/\" docker-compose up -d && docker exec -it ${PROJECT_ID} zsh")
# otherwise execute the command
else
    # add the up and exec
    COMMANDS+=("cd \"${SCRIPT_DIR}\" && HOST_PATH=\"${ROOT_DIR}/\" docker-compose up -d && docker exec -it zsh -c \"${SHELL_COMMAND}\"")
fi
# join the commands in a string and execute
COMMAND_STRING=$(printf " && %s" "${COMMANDS[@]}")
COMMAND_STRING=${COMMAND_STRING:3}

if [ -n "${DEBUG}" ]; then
  echo "${COMMAND_STRING}";
fi

eval "${COMMAND_STRING}"