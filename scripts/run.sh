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
#ROOT_DIR=$(realpath "${SCRIPT_DIR}/..")

HUGO_SOURCE="/home/${PROJECT_ID}/application/src"
HUGO_DESTINATION="/home/${PROJECT_ID}/output"

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
        --watch)
        HUGO_WATCH=true
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

WATCH="${HUGO_WATCH:=false}"
SLEEP="${HUGO_REFRESH_TIME:=-1}"

echo "HUGO_WATCH:" $WATCH
echo "HUGO_REFRESH_TIME:" $HUGO_REFRESH_TIME
echo "HUGO_THEME:" "$HUGO_THEME"
echo "HUGO_BASEURL" "$HUGO_BASEURL"
echo "ARGS" "$@"

HUGO=/usr/local/sbin/hugo

# is this the first run?
ls "${SCRIPT_DIR}"/../src/*/ >/dev/null 2>&1 ;
if [ $? != 0 ]; then
    $HUGO new site "${SCRIPT_DIR}"/../src
fi

while [ true ]
do
    if [[ $HUGO_WATCH != 'false' ]]; then
	    echo "Watching..."
        $HUGO server --watch=true --source="${HUGO_SOURCE}" --theme="$HUGO_THEME" --destination="$HUGO_DESTINATION" --baseURL="$HUGO_BASEURL" --port="$HUGO_PORT" --bind="0.0.0.0" "$@" || exit 1
    else
	    echo "Building one time..."
        $HUGO --source="${HUGO_SOURCE}" --theme="$HUGO_THEME" --destination="$HUGO_DESTINATION" --baseURL="$HUGO_BASEURL" "$@" || exit 1
    fi

    if [[ $HUGO_REFRESH_TIME == -1 ]]; then
        exit 0
    fi
    echo "Sleeping for $HUGO_REFRESH_TIME seconds..."
    sleep $SLEEP
done