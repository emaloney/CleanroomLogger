#!/bin/bash

set -e

SCRIPT_NAME=`basename $0`
SCRIPT_DIR=`dirname "$PWD/$0"`

PROJECT_DIR="$SCRIPT_DIR/../.."

if [[ ! -e "$PROJECT_DIR/.git" ]]; then
	echo "error: Expected to find git project at: $PROJECT_DIR"
	exit 1
fi

cd "$PROJECT_DIR"
PROJECT_NAME=`basename $PWD`
echo "Recursively installing all submodules in $PROJECT_NAME:"

git submodule init
git submodule update
git submodule foreach --recursive git submodule init
git submodule foreach --recursive git submodule update
