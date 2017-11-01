#!/bin/bash

#
# checks that the project builds & passes all unit tests
#
# by emaloney, 11 September 2017
#

set -o pipefail		# to ensure xcodebuild pipeline errors are propagated correctly

SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(cd "$PWD" ; cd `dirname "$0"` ; echo "$PWD")

source "${SCRIPT_DIR}/include-common.sh"

showHelp()
{
	define HELP <<HELP
$SCRIPT_NAME

	Validates that the code in this repo builds & passes all unit tests.

Usage:

	$SCRIPT_NAME

Optional arguments:

		--skip-tests
			Skips running the unit tests :-(

		--quiet
			Silences output

Help

	This documentation is displayed when supplying the --help (or -help, -h,
	or -?) argument.

	Note that when this script displays help documentation, all other
	command line arguments are ignored and no other actions are performed.

HELP
	printf "$HELP" | less
}

#
# make sure we're in a git repo
#
cd "$SCRIPT_DIR/../../."
git status 2&> /dev/null
if [[ $? != 0 ]]; then
	exitWithErrorSuggestHelp "You must invoke this script from within a git repo"
fi

#
# parse the command-line arguments
#
while [[ $1 ]]; do
	case $1 in
	--skip-tests)
		SKIP_TESTS=1
		;;

	--quiet|-q)
		QUIET=1
		QUIET_ARG="-q"
		;;

	--help|-help|-h|-\?)
		SHOW_HELP=1
		;;

	-*)
		exitWithErrorSuggestHelp "Unrecognized argument: $1"
		;;

	*)
		if [[ -z $ARGS ]]; then
			ARGS=$1
		else
			ARGS="$ARGS $1"
		fi
	esac
	shift
done

if [[ $SHOW_HELP ]]; then
	showHelp
	exit 1
fi

for ARG in $ARGS; do
	exitWithErrorSuggestHelp "Unrecognized argument: $ARG"
done

#
# make sure it builds
#
PROJECT_NAME="CleanroomLogger"
XCODEBUILD=/usr/bin/xcodebuild
XCODEBUILD_CMD="$XCODEBUILD"
if [[ $SKIP_TESTS ]]; then
	updateStatus "Verifying that $PROJECT_NAME builds"
else
	updateStatus "Verifying that $PROJECT_NAME builds and passes unit tests"
fi
if [[ $QUIET ]]; then
	XCODEBUILD_CMD="$XCODEBUILD -quiet"
fi
if [[ ! -x "$XCODEBUILD" ]]; then
	exitWithErrorSuggestHelp "Expected to find xcodebuild at path $XCODEBUILD"
fi

#
# use xcpretty if it is available
#
XCODEBUILD_PIPETO=""
XCPRETTY=`which xcpretty`
if [[ $? == 0 ]]; then
	XCODEBUILD_PIPETO="| $XCPRETTY"
fi

#
# determine build settings
#
PROJECT_SPECIFIER="-project CleanroomLogger.xcodeproj"
COMPILE_PLATFORMS="iOS macOS tvOS watchOS"

#
# build for each platform
#
for PLATFORM in $COMPILE_PLATFORMS; do
	updateStatus "Building: $PROJECT_NAME for $PLATFORM..."
	if [[ $SKIP_TESTS ]]; then
		BUILD_ACTION="clean build"
	else
		BUILD_ACTION="clean $(testActionForPlatform $PLATFORM)"
	fi
	RUN_DESTINATION="$(runDestinationForPlatform $PLATFORM)"
	if [[ $QUIET ]]; then
		executeCommand "$XCODEBUILD_CMD $PROJECT_SPECIFIER -scheme \"${PROJECT_NAME}\" -configuration Debug -destination \"$RUN_DESTINATION\" $BUILD_ACTION $XCODEBUILD_PIPETO" 2&> /dev/null
	else
		executeCommand "$XCODEBUILD_CMD $PROJECT_SPECIFIER -scheme \"${PROJECT_NAME}\" -configuration Debug -destination \"$RUN_DESTINATION\" $BUILD_ACTION $XCODEBUILD_PIPETO"
	fi
done
