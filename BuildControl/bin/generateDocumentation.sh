#!/usr/bin/env bash

if [[ "$DEVELOPER_DIR" == "/Applications/Xcode-beta.app/Contents/Developer" ]]; then
	export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

JAZZY_EXECUTABLE=`which jazzy`
if [[ $? != 0 ]]; then
	echo "error: The jazzy documentation generator must be installed. Visit https://github.com/realm/jazzy for installation information."
	exit 1
fi

pushd "`dirname $0`/../.." > /dev/null

PUBLIC_GITHUB_URL=$(git remote -v | grep fetch | awk '{ print $2 }' | sed s/.git\$// | sed s/^ssh/https/)
MODULE_NAME=`basename $PUBLIC_GITHUB_URL`
AUTHOR_GITHUB_URL=`dirname $PUBLIC_GITHUB_URL`
CURRENT_YEAR=`date +"%Y"`
COPYRIGHT_YEAR=`git log --pretty=%ad $(git rev-list --max-parents=0 HEAD) | awk '{print $5}'`
if [[ "$COPYRIGHT_YEAR" != "$CURRENT_YEAR" ]]; then
	COPYRIGHT_YEAR="${COPYRIGHT_YEAR}-${CURRENT_YEAR}"
fi

"$JAZZY_EXECUTABLE" -o Documentation \
	-m "$MODULE_NAME" \
	--readme Code/README.md \
	--github_url "$PUBLIC_GITHUB_URL" \
	--author "Evan Maloney, Gilt Groupe" \
	--author_url "$AUTHOR_GITHUB_URL" \
	--copyright "© $COPYRIGHT_YEAR [Gilt Groupe](http://tech.gilt.com/)"
JAZZY_EXIT_CODE=$?
if [[ $JAZZY_EXIT_CODE != 0 ]]; then
	echo "error: $JAZZY_EXECUTABLE failed with an exit code of $JAZZY_EXIT_CODE; check any output above for additional details."
	exit 2
fi
