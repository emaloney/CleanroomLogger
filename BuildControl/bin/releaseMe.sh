#!/bin/bash

#
# Cleanroom Project release generator script
#
# by emaloney, 7 June 2015
#

set -o pipefail		# to ensure xcodebuild pipeline errors are propagated correctly

SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(cd "$PWD" ; cd `dirname "$0"` ; echo "$PWD")

source "${SCRIPT_DIR}/include-common.sh"

showHelp()
{
	define HELP <<HELP
$SCRIPT_NAME

	Issues a new release of the project contained in this git repository.

Usage:

	$SCRIPT_NAME <release-type> [...]

Where:

	<release-type> is 'major', 'minor' or 'patch', depending on which portion
		of the version number should be incremented for this release.

Optional arguments:

		--set-version <version>
			Make <version> the version number being released

		--auto
			Run automatically without awaiting user confirmation

		--tag
			Tags the repo with the version number upon success

		--push
			Push all changes upon success

		--amend
			Causes any commits to be amends to the previous commit

		--branch <branch>
			Specifies <branch> be used as the git branch for operations

		--commit-message-file <file>
			Specifies the contents <file> should be used as the commit message

		--no-commit
			Skips committing any changes; implies --no-tag

		--no-tag
			Overrides --tag if specified; --no-tag is the default

		--stash-dirty-files
			Stashes dirty files before attempting to release

		--commit-dirty-files
			Commits dirty files before attempting to release

		--ignore-dirty-files
			Ignores dirty files; implies --no-commit --no-tag

		--skip-docs
			Skips generating the documentation

		--skip-tests
			Skips running the unit tests :-(

		--quiet
			Silences output

		--summarize
			Minimizes output (ideal for invoking from other scripts)

	Further detail can be found below.

How it works

	By default, the script inspects the appropriate property list file(s)
	to determine the current version of the project. The script then
	increments the version number according to the release type
	specified:

	major — When the major release type is specified, the major version
		component is incremented, and both the minor and patch
		components are reset to zero. 2.1.3 becomes 3.0.0.

	minor — When the minor release type is specified, the major version
		component is not changed, while the minor component is
		incremented and patch component is reset to zero.
		2.1.3 becomes 2.2.0.

	patch — When the patch release type is specified, the major and minor
		version components remain unchanged, while the patch component
		is incremented. 2.1.3 becomes 2.1.4.

	The script then updates all necessary references to the version
	elsewhere in the project.

	Then, the API documentation is rebuilt, and the repository is tagged
	with the appropriate version number for the release.

	Finally, if the --push argument was supplied, the entire release is
	pushed to the repo's origin remote.

Specifying the version explicitly

	The --set-version argument can be supplied along with a version number
	if you wish to specify the exact version number to use.

	The version number is expected to contain exactly three integer
	components separated by periods; trailing zeros are used if
	necessary.

	If you wanted to set a release version of 4.2.1, for example, you
	could call the script as follows:

		$SCRIPT_NAME --set-version 4.2.1

	NOTE: When the --set-version argument is supplied, the release-type
	      argument does not need to be specified (and it will be ignored
	      if it is).

User Confirmation

	By default, this script requires user confirmation before making
	any changes.

	To allow this script to be invoked by other scripts, an automated
	mode is also supported.

	When this script is run in automated mode, the user will not be
	asked to confirm any actions; all actions are performed immediately.

	To enable automated mode, supply the --auto argument.

Releasing with uncommitted changes

	Normally, this script will refuse to continue if the repository
	is dirty; that is, if there are any modified files that haven't
	yet been committed.

	However, you can force a release to be issued from a dirty repo
	using either the --stash-dirty-files or the --commit-dirty-files
	argument.

	The --stash-dirty-files option causes a git stash operation to
	occur at the start of the release process, and a stash pop at the
	end. This safely moves the dirty files out of the way when the
	script it doing its thing, and restores them when it is done.

	The --commit-dirty-files option causes the dirty files to be
	committed along with the other changes that occur during the
	release process.

	In addition, an --ignore-dirty-files option is available, which
	lets you go through the entire release process, but stops short
	of committing and tagging. This allows you to run through the
	entire release process without committing you to committing.

	Note that these options are mutually exclusive and may not be
	used with each other.

Help

	This documentation is displayed when supplying the --help (or -help, -h,
	or -?) argument.

	Note that when this script displays help documentation, all other
	command line arguments are ignored and no other actions are performed.

HELP
	printf "$HELP" | less
}

validateVersion()
{
	if [[ ! ($1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$) ]]; then
		exitWithErrorSuggestHelp "Expected $2 to contain three period-separated numeric components (eg., 3.6.1, 4.0.0, etc.); got $1 instead"
	fi
}

cleanupDirtyStash()
{
	updateStatus "Restoring previously-stashed modified files"
	executeCommand "git stash pop"
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
AMEND_ARGS=""
BRANCH=master
STASH_DIRTY_FILES=0
COMMIT_DIRTY_FILES=0
IGNORE_DIRTY_FILES=0
while [[ $1 ]]; do
	case $1 in
	--set-version)
		shift
		if [[ -z $1 ]]; then
			exitWithErrorSuggestHelp "The $1 argument expects a value"
		else
			validateVersion $1 "the version passed with the --set-version argument"
			SET_VERSION=$1
		fi
		;;

	--auto|-a)
		AUTOMATED_MODE=1
		;;

	--amend)
		AMEND_ARGS="--amend --no-edit"
		;;

	--stash-dirty-files)
		STASH_DIRTY_FILES=1
		;;

	--commit-dirty-files)
		COMMIT_DIRTY_FILES=1
		;;

	--ignore-dirty-files)
		IGNORE_DIRTY_FILES=1
		NO_COMMIT=1
		NO_TAG=1
		;;

	--no-commit)
		NO_COMMIT=1
		NO_TAG=1
		;;

	--no-tag)
		NO_TAG=1
		;;

	--tag)
		TAG_WHEN_DONE=1
		;;

	--push)
		PUSH_WHEN_DONE=1
		;;

	--branch|-b)
		if [[ $2 ]]; then
			BRANCH="$2"
			shift
		fi
		;;

	--commit-message-file|-m)
		if [[ $2 ]]; then
			COMMIT_MESSAGE=`cat "$2"`
			shift
		fi
		;;

	--skip-docs)
		SKIP_DOCUMENTATION=1
		;;

	--skip-tests)
		SKIP_TESTS=1
		;;

	--quiet|-q)
		QUIET=1
		QUIET_ARG="-q"
		;;

	--summarize|-z)
		SUMMARIZE=1
		QUIET=1
		QUIET_ARG="-q"
		;;

	--rebase)
		REBASE=1
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
	if [[ -z $RELEASE_TYPE ]]; then
		RELEASE_TYPE="$ARG"
	else
		exitWithErrorSuggestHelp "Unrecognized argument: $ARG"
	fi
done

#
# validate the input
#
if [[ $(( $STASH_DIRTY_FILES + $COMMIT_DIRTY_FILES + $IGNORE_DIRTY_FILES )) > 1 ]]; then
	exitWithErrorSuggestHelp "The --stash-dirty-files, --commit-dirty-files and --ignore-dirty-files arguments are mutually exclusive and can't be used with each other"
fi
if [[ ! -z $RELEASE_TYPE ]]; then
	if [[ ! -z $SET_VERSION ]]; then
		exitWithErrorSuggestHelp "The release type can't be specified when --set-version is used"
	elif [[ $RELEASE_TYPE != "major" && $RELEASE_TYPE != "minor" && $RELEASE_TYPE != "patch" ]]; then
		exitWithErrorSuggestHelp "The release type argument must be one of: 'major', 'minor' or 'patch'"
	fi
elif [[ -z $SET_VERSION ]]; then
	if [[ -z $RELEASE_TYPE ]]; then
		exitWithErrorSuggestHelp "The release type ('major', 'minor' or 'patch') must be specified as an argument."
	fi
fi

#
# figure out what the current version is
#
FRAMEWORK_PLIST_FILE="Info-Target.plist"
FRAMEWORK_PLIST_PATH="$SCRIPT_DIR/../$FRAMEWORK_PLIST_FILE"
PLIST_BUDDY=/usr/libexec/PlistBuddy
CURRENT_VERSION=`$PLIST_BUDDY "$FRAMEWORK_PLIST_PATH" -c "Print :CFBundleShortVersionString"`
validateVersion "$CURRENT_VERSION" "the CFBundleShortVersionString value in the $FRAMEWORK_PLIST_FILE file"

#
# now, do the right thing depending on the command-line arguments
#
if [[ ! -z $SET_VERSION ]]; then
	VERSION=$SET_VERSION
elif [[ ! -z $RELEASE_TYPE ]]; then
	MAJOR_VERSION=`echo $CURRENT_VERSION | awk -F . '{print int($1)}'`
	MINOR_VERSION=`echo $CURRENT_VERSION | awk -F . '{print int($2)}'`
	PATCH_VERSION=`echo $CURRENT_VERSION | awk -F . '{print int($3)}'`

	case $RELEASE_TYPE in
	major)
		MAJOR_VERSION=$(( $MAJOR_VERSION + 1 ))
		MINOR_VERSION=0
		PATCH_VERSION=0
		;;

	minor)
		MINOR_VERSION=$(( $MINOR_VERSION + 1 ))
		PATCH_VERSION=0
		;;

	patch)
		PATCH_VERSION=$(( $PATCH_VERSION + 1 ))
		;;
	esac

	VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}"
fi

#
# try to figure out the origin repo name
#
REPO_NAME=$(git remote -v | grep "^origin" | grep "(fetch)" | awk '{print $2}' | xargs basename | sed 'sq.git$qq')
if [[ -z "$REPO_NAME" ]]; then
	exitWithErrorSuggestHelp "Couldn't determine repo name"
fi

#
# output a warning if there are conflicting tag flags
#
if [[ $TAG_WHEN_DONE && $NO_TAG ]]; then
	exitWithErrorSuggestHelp "--tag can't be specified with --no-tag, --no-commit or --ignore-dirty-files"
fi

#
# see if we've got uncommitted changes
#
git rev-parse --quiet --verify HEAD > /dev/null
if [[ $? == 0 ]]; then
	git diff-index --quiet HEAD -- ; REPO_IS_DIRTY=$?
else
	# if HEAD doesn't exist (which is how we get here), then treat the
	# repo as if it were dirty
	REPO_IS_DIRTY=1
fi
if [[ $REPO_IS_DIRTY != 0 && $(( $STASH_DIRTY_FILES + $COMMIT_DIRTY_FILES + $IGNORE_DIRTY_FILES )) == 0 ]]; then
	exitWithErrorSuggestHelp "You have uncommitted changes in this repo; won't do anything" "(use --stash-dirty-files, --commit-dirty-files or\n\t--ignore-dirty-files to bypass this error)"
fi
REPO_URL=`git remote get-url --push origin 2> /dev/null`
if [[ $? == 0 ]]; then
	git ls-remote --heads $REPO_URL $BRANCH | grep "refs/heads/$BRANCH" > /dev/null
	if [[ $? == 0 ]]; then
		REMOTE_BRANCH_EXISTS=1
	fi
fi
if [[ ! $REMOTE_BRANCH_EXISTS ]]; then
	GIT_PUSH_ARGS="--set-upstream origin $BRANCH"
fi

confirmationPrompt "Releasing $REPO_NAME $VERSION (current is $CURRENT_VERSION)"

if [[ $REPO_IS_DIRTY && $STASH_DIRTY_FILES > 0 ]]; then
	updateStatus "Stashing modified files"
	executeCommand "git stash"
    trap cleanupDirtyStash EXIT
fi

#
# make sure it builds
#
XCODEBUILD=/usr/bin/xcodebuild
XCODEBUILD_CMD="$XCODEBUILD"
updateStatus "Verifying that $REPO_NAME builds"
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
PROJECT_NAME="CleanroomLogger"

#
# build for each platform
#
for PLATFORM in $COMPILE_PLATFORMS; do
	updateStatus "Building: $PROJECT_NAME for $PLATFORM..."
	summarize "building $PROJECT_NAME for $PLATFORM"
	if [[ $SKIP_TESTS ]]; then
		BUILD_ACTION="clean build"
	else
		BUILD_ACTION="clean $(testActionForPlatform $PLATFORM)"
	fi
	RUN_DESTINATION="$(runDestinationForPlatform $PLATFORM)"
	if [[ $QUIET ]]; then
		executeCommand "$XCODEBUILD_CMD $PROJECT_SPECIFIER -scheme \"${REPO_NAME}\" -configuration Debug -destination \"$RUN_DESTINATION\" $BUILD_ACTION $XCODEBUILD_PIPETO" 2&> /dev/null
	else
		executeCommand "$XCODEBUILD_CMD $PROJECT_SPECIFIER -scheme \"${REPO_NAME}\" -configuration Debug -destination \"$RUN_DESTINATION\" $BUILD_ACTION $XCODEBUILD_PIPETO"
	fi
done

#
# bump version numbers
#
updateStatus "Adjusting version numbers"
executeCommand "$PLIST_BUDDY \"$FRAMEWORK_PLIST_PATH\" -c \"Set :CFBundleShortVersionString $VERSION\""
agvtool bump > /dev/null
summarize "bumped version to $VERSION from $CURRENT_VERSION for $RELEASE_TYPE release"

#
# commit changes
#
BUILD_NUMBER=`agvtool vers -terse`
if [[ -z $COMMIT_MESSAGE ]]; then
	COMMIT_MESSAGE="Release $VERSION (build $BUILD_NUMBER)"
	if [[ $REPO_IS_DIRTY && $COMMIT_DIRTY_FILES > 0 ]]; then
		COMMIT_MESSAGE="$COMMIT_MESSAGE -- committed with other changes"
	fi
else
	COMMIT_MESSAGE="[$VERSION] $COMMIT_MESSAGE"
fi
if [[ -z $NO_COMMIT ]]; then
	updateStatus "Committing changes"
	printf "%s" "$COMMIT_MESSAGE" | git commit -a $QUIET_ARG $AMEND_ARGS -F -
	summarize "committed changes to \"$BRANCH\" branch"
else
	updateStatus "! Not committing changes; --no-commit or --ignore-dirty-files was specified"
	printf "> To commit manually, use:\n\n    git commit -a -m '$COMMIT_MESSAGE'\n"
fi

#
# rebase with existing changes if needed
#
if [[ $REBASE && $REMOTE_BRANCH_EXISTS ]]; then
	updateStatus "Rebasing with existing $BRANCH branch"
	executeCommand "git pull origin $BRANCH $QUIET_ARG --rebase --allow-unrelated-histories --strategy=recursive -Xtheirs"
	summarize "rebased \"$BRANCH\" branch"
fi

#
# tag repo with new version number
#
if [[ $TAG_WHEN_DONE && -z $NO_COMMIT && -z $NO_TAG ]]; then
	updateStatus "Tagging repo for $VERSION release"
	executeCommand "git tag -a $VERSION -m 'Release $VERSION issued by $SCRIPT_NAME'"
	summarize "tagged \"$BRANCH\" branch with $VERSION"
else
	updateStatus "! Not tagging repo; --tag was not specified"
	printf "> To tag manually, use:\n\n    git tag -a $VERSION -m 'Release $VERSION issued by $SCRIPT_NAME'\n"
fi

#
# push if we should
#
if [[ $PUSH_WHEN_DONE && -z $NO_COMMIT ]]; then
	ORIGIN_URL=`git remote get-url --push origin`
	updateStatus "Pushing changes to \"$BRANCH\" branch of $ORIGIN_URL"
	executeCommand "git push $QUIET_ARG $GIT_PUSH_ARGS"
	if [[ $TAG_WHEN_DONE && !$NO_TAG ]]; then
		executeCommand "git push --tags $QUIET_ARG"
	fi
	summarize "pushed changes to \"$BRANCH\" branch of $ORIGIN_URL"
else
	printf "\n> REMEMBER: The release isn't done until you push the changes! Don't forget to:\n\n    git push && git push --tags\n"
fi
