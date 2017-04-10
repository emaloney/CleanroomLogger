#!/usr/bin/env bash

JAZZY_EXECUTABLE=`which jazzy`
if [[ $? != 0 ]]; then
	echo "error: The jazzy documentation generator must be installed. Visit https://github.com/realm/jazzy for installation information."
	exit 1
fi

pushd "`dirname $0`/../.." > /dev/null

PUBLIC_GITHUB_URL="https://github.com/emaloney/CleanroomLogger"
if [[ -z "$PUBLIC_GITHUB_URL" ]]; then
	PUBLIC_GITHUB_URL=$(git remote -v | grep fetch | awk '{ print $2 }' | sed s/.git\$// | sed s/^ssh/https/ | sed s#git@github.com:#https://github.com/# )
fi
MODULE_NAME=`basename $PUBLIC_GITHUB_URL`
AUTHOR_GITHUB_URL=`dirname $PUBLIC_GITHUB_URL`
CURRENT_YEAR=`date +"%Y"`
COPYRIGHT_YEAR=`git log --pretty=%ad $(git rev-list --max-parents=0 HEAD) | awk '{print $5}'`
if [[ "$COPYRIGHT_YEAR" != "$CURRENT_YEAR" ]]; then
	COPYRIGHT_YEAR="${COPYRIGHT_YEAR}-${CURRENT_YEAR}"
fi

rm -rf Documentation/API	# clear out any old docs; they may have remnant files

"$JAZZY_EXECUTABLE" -o Documentation/API \
	--module "$MODULE_NAME" \
	--readme Sources/README.md \
	--github_url "$PUBLIC_GITHUB_URL" \
	--author "Evan Maloney, Gilt Groupe" \
	--author_url "$AUTHOR_GITHUB_URL" \
	--copyright "© $COPYRIGHT_YEAR [Gilt Groupe](http://tech.gilt.com/)"

JAZZY_EXIT_CODE=$?
if [[ $JAZZY_EXIT_CODE != 0 ]]; then
	echo "error: $JAZZY_EXECUTABLE failed with an exit code of $JAZZY_EXIT_CODE; check any output above for additional details."
	exit 2
fi
