#!/bin/bash
os="$(uname -s)"
if [ ${os} = "Linux" ]; then
    echo "Linux OS detected"
    current_dir=$(dirname $(readlink -f $0))
elif [ ${os} = "Darwin" ]; then
    echo "MacOS detected"
    current_dir=$(cd "$(dirname "$0")"; pwd)
fi

# Check we have our .env file
if [ ! -f ${current_dir}/.env ]; then
    echo ".env file not found! Please create it copying from .env.template provided"
    exit 1;
fi

# get our arguments
POSITIONAL=()
COMMANDS=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --build)
        COMMANDS+="HOST_PATH=\"$(pwd)\" docker-compose -f ./docker-compose.yml build --no-cache"
        shift # past argument
        ;;

        -c|--command)
        shift # past argument
        SHELL_COMMAND=$1
        shift # past argument
        ;;

        *) # unknown option
        POSITIONAL+=("$1") # addOne it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# read the .env file
DOCKER_ENV=()
DOCKER_ENV+=$(grep -v '^#' "${current_dir}/.env" | xargs)
# add them to this script too
export $(grep -v '^#' ${current_dir}/.env | xargs)

# check fo the project id
if [ -z ${PROJECT_ID} ]; then
    echo "PROJECT_ID is not set"
    exit 0;
fi

# if we have no command (like for instance passed by the CI) just run zsh
if [ -z "${SHELL_COMMAND}" ]; then
    echo "No command passed";
    COMMANDS+=("HOST_PATH=\"$(pwd)\" docker-compose -f ./docker-compose.yml up -d && docker exec -it hugo_${PROJECT_ID} zsh -c \"../scripts/run.sh\"")
# otherwise execute the command
else
    # add the up and exec
    COMMANDS+=("HOST_PATH=\"$(pwd)\" docker-compose -f ./docker-compose.yml up -d && docker exec -it hugo_${PROJECT_ID} zsh -c \"${SHELL_COMMAND}\"")
fi

# join the commands in a string and execute
COMMAND_STRING=$(printf " && %s" "${COMMANDS[@]}")
COMMAND_STRING=${COMMAND_STRING:3}
eval "${COMMAND_STRING}"