#!/bin/bash

#
# Cleanroom Project release generator script
#
# by emaloney, 7 June 2015
#

set -o pipefail		# to ensure xcodebuild pipeline errors are propagated correctly

SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(cd "$PWD" ; cd `dirname "$0"` ; echo "$PWD")

showHelp()
{
	echo "$SCRIPT_NAME"
	echo
	printf "\tGenerates a new release of the project contained in this git\n"
	printf "\trepository.\n"
	echo
	echo "Usage:"
	echo
	printf "\t$SCRIPT_NAME <release-type>\n"
	echo
	echo "Where:"
	echo
	printf "\t<release-type> is 'major', 'minor' or 'patch', depending on which\n"
	printf "\t\tportion of the version number should be incremented for this\n"
	printf "\t\trelease.\n"
	echo
	printf "\tThis script also accepts these optional command-line arguments:\n"
	echo
	printf "\t\t--set-version <version>\n"
	printf "\t\t\tMake <version> the version number being released\n"
	echo
	printf "\t\t--auto\n"
	printf "\t\t\tRun automatically without awaiting user confirmation\n"
	echo
	printf "\t\t--tag\n"
	printf "\t\t\tTags the repo with the version number upon success\n"
	echo
	printf "\t\t--push\n"
	printf "\t\t\tPush all changes upon success\n"
	echo
	printf "\t\t--no-commit\n"
	printf "\t\t\tSkips committing any changes; implies --no-tag\n"
	echo
	printf "\t\t--no-tag\n"
	printf "\t\t\tOverrides --tag if specified; --no-tag is the default\n"
	echo
	printf "\t\t--stash-dirty-files\n"
	printf "\t\t\tStashes dirty files before attempting to release\n"
	echo
	printf "\t\t--commit-dirty-files\n"
	printf "\t\t\tCommits dirty files before attempting to release\n"
	echo
	printf "\t\t--ignore-dirty-files\n"
	printf "\t\t\tIgnores dirty files; implies --no-commit --no-tag\n"
	echo
	printf "\t\t--skip-docs\n"
	printf "\t\t\tSkips generating the documentation\n"
	echo
	printf "\t\t--skip-tests\n"
	printf "\t\t\tSkips running the unit tests :-(\n"
	echo
	printf "\t\t--dry-run\n"
	printf "\t\t\tShow commands to be executed instead of executing them\n"
	echo
	printf "\tFurther detail about these options can be found below.\n"
	echo
	echo "How it works"
	echo
	printf "\tBy default, the script inspects the appropriate property list file(s)\n"
	printf "\tto determine the current version of the project. The script then\n"
	printf "\tincrements the version number according to the release type\n"
	printf "\tspecified:\n"
	echo
	printf "\tmajor — When the major release type is specified, the major version\n"
	printf "\t\tcomponent is incremented, and both the minor and patch\n"
	printf "\t\tcomponents are reset to zero. 2.1.3 becomes 3.0.0.\n"
	echo
	printf "\tminor — When the minor release type is specified, the major version\n"
	printf "\t\tcomponent is not changed, while the minor component is\n"
	printf "\t\tincremented and patch component is reset to zero.\n"
	printf "\t\t2.1.3 becomes 2.2.0.\n"
	echo
	printf "\tpatch — When the patch release type is specified, the major and minor\n"
	printf "\t\tversion components remain unchanged, while the patch component\n"
	printf "\t\tis incremented. 2.1.3 becomes 2.1.4.\n"
	echo
	printf "\tThe script then updates all necessary references to the version\n"	
	printf "\telsewhere in the project.\n"
	echo
	printf "\tThen, the API documentation is rebuilt, and the repository is tagged\n"
	printf "\twith the appropriate version number for the release.\n"
	echo
	printf "\tFinally, if the --push argument was supplied, the entire release is\n"	
	printf "\tpushed to the repo's origin remote.\n"	
	echo
	echo "Specifying the version explicitly"
	echo
	printf "\tThe --set-version argument can be supplied along with a version number\n"
	printf "\tif you wish to specify the exact version number to use.\n"
	echo
	printf "\tThe version number is expected to contain exactly three integer\n"
	printf "\tcomponents separated by periods; trailing zeros are used if\n"
	printf "\tnecessary.\n"
	echo
	printf "\tIf you wanted to set a release version of 4.2.1, for example, you\n"
	printf "\tcould call the script as follows:\n"
	echo
	printf "\t\t$SCRIPT_NAME --set-version 4.2.1\n"
	echo
	printf "\tNOTE: When the --set-version argument is supplied, the release-type\n"
	printf "\t      argument does not need to be specified (and it will be ignored\n"
	printf "\t      if it is).\n"
	echo
	echo "User Confirmation"
	echo
	printf "\tBy default, this script requires user confirmation before making\n"
	printf "\tany changes.\n"
	echo
	printf "\tTo allow this script to be invoked by other scripts, an automated\n"
	printf "\tmode is also supported.\n"
	echo
	printf "\tWhen this script is run in automated mode, the user will not be\n"
	printf "\tasked to confirm any actions; all actions are performed immediately.\n"
	echo
	printf "\tTo enable automated mode, supply the --auto argument.\n"
	echo
	echo "Releasing with uncommitted changes"
	echo
	printf "\tNormally, this script will refuse to continue if the repository\n"
	printf "\tis dirty; that is, if there are any modified files that haven't\n"
	printf "\tyet been committed.\n"
	echo
	printf "\tHowever, you can force a release to be issued from a dirty repo\n"
	printf "\tusing either the --stash-dirty-files or the --commit-dirty-files\n"
	printf "\targument.\n"
	echo
	printf "\tThe --stash-dirty-files option causes a git stash operation to\n"
	printf "\toccur at the start of the release process, and a stash pop at the\n"
	printf "\tend. This safely moves the dirty files out of the way when the\n"
	printf "\tscript it doing its thing, and restores them when it is done.\n"
	echo	
	printf "\tThe --commit-dirty-files option causes the dirty files to be\n"
	printf "\tcommitted along with the other changes that occur during the\n"
	printf "\trelease process.\n"
	echo	
	printf "\tIn addition, an --ignore-dirty-files option is available, which\n"
	printf "\tlets you go through the entire release process, but stops short\n"
	printf "\tof committing and tagging. This allows you to run through the\n"
	printf "\tentire release process without committing you to committing.\n"
	echo
	printf "\tNote that these options are mutually exclusive and may not be\n"
	printf "\tused with each other.\n"
	echo
	echo "Dry run mode"
	echo
	printf "\tUsing the --dry-run argument prevents the release from occurring\n"
	printf "\tand instead shows what would occur if the release were to be\n"
	printf "\texecuted using the supplied command-line arguments.\n"
	echo
	echo "Help"
	echo
	printf "\tThis documentation is displayed when supplying the --help (or\n"
	printf "\t-h or -?) argument.\n"
	echo
	printf "\tNote that when this script displays help documentation, all other\n"
	printf "\tcommand line arguments are ignored and no other actions are performed.\n"
	echo
}

printError()
{
	echo "error: $1"
	echo
	if [[ ! -z $2 ]]; then
		printf "  $2\n\n"
	fi
}

exitWithError()
{
	printError "$1" "$2"
	exit 1
}

exitWithErrorSuggestHelp()
{
	printError "$1" "$2"
	printf "  To display help, run:\n\n\t$0 --help\n"
	exit 1
}

validateVersion()
{
	if [[ ! ($1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$) ]]; then
		exitWithErrorSuggestHelp "Expected $2 to contain three period-separated numeric components (eg., 3.6.1, 4.0.0, etc.); got $1 instead"
	fi
}

updateStatus()
{
	echo 
	echo "$1"
	echo
}

confirmationPrompt()
{
	echo
	echo $1
	if [[ -z $AUTOMATED_MODE ]]; then
		echo
		read -p "Are you sure you want to do this? " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			exit -1
		fi
	fi
}

executeCommand()
{
	if [[ $DRY_RUN_MODE ]]; then
		if [[ ! $DID_DRY_RUN_MSG ]]; then
			printf "\t!!! DRY RUN MODE - Will only show commands, not execute them !!!\n"
			echo
			DID_DRY_RUN_MSG=1
		fi
		echo "> executing: "
		echo
		echo "	set -o pipefail && $1"
	else
		eval "set -o pipefail && $1"
		if [[ $? != 0 ]]; then
			exitWithError "Command failed"
		fi
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
	
	--skip-docs)
		SKIP_DOCUMENTATION=1
		;;
		
	--skip-tests)
		SKIP_TESTS=1
		;;
		
	--dry-run)
		DRY_RUN_MODE=1
		;;
	
	--help|-h|-\?)
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
PLIST_BUDDY=/usr/libexec/PlistBuddy
if [[ ! -x "$PLIST_BUDDY" ]]; then
	exitWithErrorSuggestHelp "Expected to find PlistBuddy at path $PLIST_BUDDY"
fi
FRAMEWORK_PLIST_FILE="Info-Framework.plist"
FRAMEWORK_PLIST_PATH="$SCRIPT_DIR/../$FRAMEWORK_PLIST_FILE"
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
git diff-index --quiet HEAD -- ; REPO_IS_DIRTY=$?
if [[ $REPO_IS_DIRTY != 0 && $(( $STASH_DIRTY_FILES + $COMMIT_DIRTY_FILES + $IGNORE_DIRTY_FILES )) == 0 ]]; then
	exitWithErrorSuggestHelp "You have uncommitted changes in this repo; won't do anything" "(use --stash-dirty-files, --commit-dirty-files or\n\t--ignore-dirty-files to bypass this error)"
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
updateStatus "Verifying that $REPO_NAME builds"
XCODEBUILD=/usr/bin/xcodebuild
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

testActionForPlatform()
{
	case $1 in
	iOS) 		echo "test";;
	macOS) 		echo "test";;	
	tvOS) 		echo "test";;
	watchOS)	echo "build";;
	esac
}

runDestinationForPlatform()
{
	case $1 in
	iOS) 		echo "platform=iOS Simulator,OS=10.3,name=iPad Air 2";;
	macOS) 		echo "platform=macOS";;	
	tvOS) 		echo "platform=tvOS Simulator,OS=10.2,name=Apple TV 1080p";;
	watchOS)	echo "platform=watchOS Simulator,OS=3.2,name=Apple Watch Series 2 - 42mm";;
	esac
}

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
	executeCommand "$XCODEBUILD $PROJECT_SPECIFIER -scheme \"${REPO_NAME}\" -configuration Debug -destination \"$RUN_DESTINATION\" $BUILD_ACTION $XCODEBUILD_PIPETO"
done

#
# bump version numbers
#
updateStatus "Adjusting version numbers"
executeCommand "$PLIST_BUDDY \"$FRAMEWORK_PLIST_PATH\" -c \"Set :CFBundleShortVersionString $VERSION\""
executeCommand "agvtool bump"

if [[ ! $SKIP_DOCUMENTATION ]]; then
	updateStatus "Rebuilding documentation"
	executeCommand "$SCRIPT_DIR/generateDocumentationForAPI.sh"
	executeCommand "git add Documentation/."
fi

#
# commit changes
#
BUILD_NUMBER=`agvtool vers -terse`
COMMIT_COMMENT="Release $VERSION (build $BUILD_NUMBER)"
if [[ $REPO_IS_DIRTY && $COMMIT_DIRTY_FILES > 0 ]]; then
	COMMIT_COMMENT="$COMMIT_COMMENT -- committed with other changes"
fi
if [[ -z $NO_COMMIT ]]; then
	updateStatus "Committing changes"
	executeCommand "git commit -a -m '$COMMIT_COMMENT'"
else
	updateStatus "! Not committing changes; --no-commit or --ignore-dirty-files was specified"
	printf "> To commit manually, use:\n\n    git commit -a -m '$COMMIT_COMMENT'\n"
fi

#
# tag repo with new version number
#
if [[ $TAG_WHEN_DONE && -z $NO_COMMIT && -z $NO_TAG ]]; then
	updateStatus "Tagging repo for $VERSION release"
	executeCommand "git tag -a $VERSION -m 'Release $VERSION issued by $SCRIPT_NAME'"
else
	updateStatus "! Not tagging repo; --tag was not specified"
	printf "> To tag manually, use:\n\n    git tag -a $VERSION -m 'Release $VERSION issued by $SCRIPT_NAME'\n"
fi

#
# push if we should
#
if [[ $PUSH_WHEN_DONE && -z $NO_COMMIT ]]; then
	updateStatus "Pushing changes to origin"
	executeCommand "git push"
	if [[ $TAG_WHEN_DONE && !$NO_TAG ]]; then
		executeCommand "git push --tags"
	fi
else
	printf "\n> REMEMBER: The release isn't done until you push the changes! Don't forget to:\n\n    git push && git push --tags\n"
fi
