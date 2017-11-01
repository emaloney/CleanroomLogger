#!/bin/bash

#
# validates that a pull request builds & passes all unit tests
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

	Validates that a pull request builds & passes all unit tests.

Usage:

	$SCRIPT_NAME <branch> [--owner <owner>]

Where:

	<branch> is the GitHub branch published by <author> that corresponds to the
	given pull request being validated.

	<owner> is the GitHub organization or user under which the pull request
	was posted. This argument may be omitted if <owner> is the same as the
	owner of this repo.

Optional arguments:

		-o <owner>
		    Shorthand for --owner <owner>

		--skip-tests
			Skips running the unit tests :-(

		--quiet (or -q)
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
# figure out the default --owner
#
ORIGIN_URL=`git remote get-url origin`
if [[ `echo $ORIGIN_URL | grep -c "^https://"` > 0 ]]; then
	DEFAULT_OWNER=`echo $ORIGIN_URL | sed "sq^https://.*github.com/qq" | sed "sq/.*qq"`
elif [[ `echo $ORIGIN_URL | grep -c "^ssh://"` > 0 ]]; then
	DEFAULT_OWNER=`echo $ORIGIN_URL | sed "sq^ssh://.*github.com/qq" | sed "sq/.*qq"`
else
	DEFAULT_OWNER=`echo $ORIGIN_URL | sed "sq.*:qq" | sed "sq/.*qq"`
fi

#
# parse the command-line arguments
#
QUIET_ARG=""
OWNER="$DEFAULT_OWNER"
while [[ $1 ]]; do
	case $1 in
	--owner|-o)
		if [[ $2 ]]; then
			OWNER="$2"
			shift
		fi
		;;

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
		if [[ -z $BRANCH ]]; then
			BRANCH=$1
		elif [[ -z $ARGS ]]; then
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

if [[ -z $BRANCH ]]; then
	exitWithErrorSuggestHelp "The pull request branch name must be specified"
fi

for ARG in $ARGS; do
	exitWithErrorSuggestHelp "Unrecognized argument: $ARG"
done

#
# clone the repo using the pull request branch
#
PROJECT_NAME="CleanroomLogger"
REPO_URL="ssh://github.com/$OWNER/$PROJECT_NAME"
REPO_TEMP_DIR=`mktemp -d`
updateStatus "Cloning $BRANCH from $REPO_URL into $REPO_TEMP_DIR"
cd "$REPO_TEMP_DIR"
executeCommand "git clone --recursive $QUIET_ARG -b $BRANCH $REPO_URL"
cd "$PROJECT_NAME"

#
# execute buildCheck.sh, preferring the one in the repo (if any)
#
BUILD_CHECK_SCRIPT="BuildControl/bin/buildCheck.sh"
if [[ -e "$BUILD_CHECK_SCRIPT" ]]; then
	executeCommand "$BUILD_CHECK_SCRIPT $QUIET_ARG"
else
	exitWithError "Couldn't find expected script at $PWD/$BUILD_CHECK_SCRIPT"
fi

updateStatus "Success! The $BRANCH branch of $PROJECT_NAME passes all checks."
