#!/bin/bash

SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(cd "$PWD" ; cd `dirname "$0"` ; echo "$PWD")

PLATE_EXECUTABLE=$( which plate )
if [[ $? != 0 ]]; then
	echo "error: Couldn't find 'plate' executable; available at https://github.com/emaloney/Boilerplate"
	exit 1
fi

cd "${SCRIPT_DIR}/../../"

PROJECT_XML=BuildControl/CleanroomLogger.xml
REPOS_XML=BuildControl/repos.xml
FILE_COUNT=0

echo "Searching for boilerplate files in $PWD"

for f in `find . -name "*.boilerplate"`
do
	BOILERPLATE_FILE="$f"
	OUTPUT_FILE=$( echo $f | sed sq.boilerplate\$qq )

	ECHO_OUTPUT_FILE=$( basename "$OUTPUT_FILE" )
	echo "	$BOILERPLATE_FILE -> $ECHO_OUTPUT_FILE"
	"$PLATE_EXECUTABLE" -t "$BOILERPLATE_FILE" -d "$PROJECT_XML" -m "$REPOS_XML" -o "$OUTPUT_FILE"
	if [[ $? == 0 ]]; then
		FILE_COUNT=$(( $FILE_COUNT + 1 ))
	else
		exit 2
	fi
done

if [[ $FILE_COUNT == 0 ]]; then
	echo "No boilerplate files found."
elif [[ $FILE_COUNT == 1 ]]; then
	echo "Successfully processed $FILE_COUNT boilerplate file"
else
	echo "Successfully processed $FILE_COUNT boilerplate files"
fi
