#!/usr/bin/env bash

JAZZY_EXECUTABLE=`which jazzy`
if [[ $? != 0 ]]; then
	echo "error: The jazzy documentation generator must be installed. Visit https://github.com/realm/jazzy for installation information."
	exit 1
fi

pushd "`dirname $0`/../.." > /dev/null

MODULE_NAME=`basename $PWD`

"$JAZZY_EXECUTABLE" -o Documentation -m "$MODULE_NAME" --readme Code/README.md --github_url "https://github.com/emaloney/$MODULE_NAME" --author "Gilt Groupe" --author_url "http://tech.gilt.com/"
JAZZY_EXIT_CODE=$?
if [[ $JAZZY_EXIT_CODE != 0 ]]; then
	echo "error: $JAZZY_EXECUTABLE failed with an exit code of $JAZZY_EXIT_CODE; check any output above for additional details."
	exit 2
fi
