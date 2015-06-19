#!/usr/bin/env bash

while [[ $1 ]]; do
	case $1 in
	--platform|-p)
		shift
		if [[ ! -z "$1" ]]; then
			PLATFORM=$1
		fi
		;;
		
	*)
		if [[ -z "$ARGS" ]]; then
			ARGS=$1		
		else
			ARGS="$ARGS $1"
		fi
	esac
	shift
done

exitWithError()
{
	echo "error: $2"
	exit $1
}

#
# reject any unrecognized arguments
#
if [[ ! -z "$ARGS" ]]; then
	exitWithError 1 "The script was passed unrecognized parameters: $ARGS"
fi

#
# make sure we've been passed the PROJECT_DIR variable from Xcode
#
if [[ -z "$PROJECT_DIR" ]]; then
	exitWithError 3 "The PROJECT_DIR environment variable must be set to the directory containing the Xcode project file"
fi

#
# make sure the Carthage file structure is what we expect
#
CARTHAGE_ROOT="$PROJECT_DIR/Carthage"
if [[ ! -d "$CARTHAGE_ROOT" ]]; then
	exitWithError 4 "Expected to find Carthage directory at: $CARTHAGE_ROOT"
fi

CARTHAGE_BUILD_DIR="$CARTHAGE_ROOT/Build"
if [[ ! -d "$CARTHAGE_BUILD_DIR" ]]; then
	exitWithError 5 "Expected to find Carthage build directory at: $CARTHAGE_BUILD_DIR"
fi

#
# figure out what the valid platforms are
#
PLAT_COUNT=0
for PLAT_PATH in "$CARTHAGE_BUILD_DIR/"*; do
	PLAT=`basename $PLAT_PATH`

	if [[ -z "$VALID_PLATFORMS" ]]; then
		VALID_PLATFORMS=$PLAT	
	else
		VALID_PLATFORMS="$VALID_PLATFORMS $PLAT"
	fi

	PLAT_COUNT=$(( $PLAT_COUNT + 1 ))
done

#
# if no --platform was explicitly specified, see if there's only one
#
if [[ -z "$PLATFORM" ]]; then
	if [[ $PLAT_COUNT > 1 ]]; then
		exitWithError 6 "The --platform (-p) parameter must be specified when more than one platform is available; the following platforms are available: $VALID_PLATFORMS"
	fi
	PLATFORM=$PLAT
fi

#
# validate the platform
#
CARTHAGE_PLATFORM_DIR="$CARTHAGE_BUILD_DIR/$PLATFORM"
if [[ ! -d "$CARTHAGE_PLATFORM_DIR" ]]; then
	exitWithError 7 "Unknown platform: \"$PLATFORM\"; acceptable values for this build: $VALID_PLATFORMS"
fi

#
# if we got here, everything's good; construct the environment
# variables that will be expected by "carthage copy-frameworks"
#
FRAMEWORK_COUNT=0
for FRAMEWORK in "$CARTHAGE_PLATFORM_DIR/"*.framework; do
	export SCRIPT_INPUT_FILE_${FRAMEWORK_COUNT}="$FRAMEWORK"
	FRAMEWORK_COUNT=$(( $FRAMEWORK_COUNT + 1 ))
done
export SCRIPT_INPUT_FILE_COUNT=$FRAMEWORK_COUNT

/usr/bin/env /usr/local/bin/carthage copy-frameworks
