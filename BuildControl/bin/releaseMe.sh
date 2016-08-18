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
	printf "\t\t--push\n"
	printf "\t\t\tPush all changes when finished\n"
	echo
	printf "\t\t--stash-dirty-files\n"
	printf "\t\t\tStashes dirty files before attempting to release a repo\n"
	echo
	printf "\t\t--commit-dirty-files\n"
	printf "\t\t\tReleases a dirty repo by committing dirty files\n"
	echo
	printf "\t\t--skip-docs\n"
	printf "\t\t\tSkips generating the documentation\n"
	echo
	printf "\t\t--skip-tests\n"
	printf "\t\t\tSkips running the unit tests :-(\n"
	echo
	printf "\t\t--untag <version>\n"
	printf "\t\t\tRemove the repo tags for <version>\n"
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
	printf "\t\tcomponents are reset to zero. (eg., 2.1.3 becomes 3.0.0)\n"
	echo
	printf "\tminor — When the minor release type is specified, the major version\n"
	printf "\t\tcomponent is not changed, while the minor component is\n"
	printf "\t\tincremented and patch component is reset to zero.\n"
	printf "\t\t(eg., 2.1.3 becomes 2.2.0)\n"
	echo
	printf "\tpatch — When the patch release type is specified, the major and minor\n"
	printf "\t\tversion components remain unchanged, while the patch component\n"
	printf "\t\tis incremented. (eg., 2.1.3 becomes 2.1.4)\n"
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
	echo "Untagging a release"
	echo
	printf "\tThe script can also take an --untag <version> argument where a\n"
	printf "\tpreviously-applied tag will be deleted from the repo."
	echo
	printf "\tTo remove the tag for version 4.2.1, you would execute:\n"
	echo
	printf "\t\t$SCRIPT_NAME --untag 4.2.1\n"
	echo
	printf "\tNOTE: As with the --set-version argument, when --untag is used,\n"
	printf "\t      specifying a release-type has no effect.\n"
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
		echo "> $1"
	else
		eval "$1"
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
while [[ $1 ]]; do
	case $1 in
	--untag)
		shift
		if [[ -z $1 ]]; then
			exitWithErrorSuggestHelp "The $1 argument expects a value"
		else
			validateVersion $1 "the version passed with the --untag argument"
			UNTAG_VERSION=$1
		fi
		;;
	
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
		
	--skip-docs)
		SKIP_DOCUMENTATION=1
		;;
		
	--skip-tests)
		SKIP_TESTS=1
		;;
		
	--dry-run)
		DRY_RUN_MODE=1
		;;
	
	--push)
		PUSH_WHEN_DONE=1
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
if [[ $STASH_DIRTY_FILES && $COMMIT_DIRTY_FILES ]]; then
	exitWithErrorSuggestHelp "The --stash-dirty-files and --commit-dirty-files arguments are mutually exclusive and can't be used with each other"
fi
if [[ ! -z $UNTAG_VERSION && ! -z $SET_VERSION ]]; then
	exitWithErrorSuggestHelp "The --untag and --set-version arguments are mutually exclusive and can't be used with each other"
fi
if [[ ! -z $RELEASE_TYPE ]]; then
	if [[ ! -z $UNTAG_VERSION ]]; then
		exitWithErrorSuggestHelp "The release type can't be specified when --untag is used"
	elif [[ ! -z $SET_VERSION ]]; then
		exitWithErrorSuggestHelp "The release type can't be specified when --set-version is used"
	elif [[ $RELEASE_TYPE != "major" && $RELEASE_TYPE != "minor" && $RELEASE_TYPE != "patch" ]]; then
		exitWithErrorSuggestHelp "The release type argument must be one of: 'major', 'minor' or 'patch'"
	fi
elif [[ -z $UNTAG_VERSION && -z $SET_VERSION ]]; then
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
if [[ ! -z $UNTAG_VERSION ]]; then
	confirmationPrompt "Removing repo tag for version $UNTAG_VERSION"

	updateStatus "Deleting tag for $UNTAG_VERSION release"

	#
	# we're being asked to untag a previous version; easy peasy
	#
	executeCommand "git tag --delete $UNTAG_VERSION"
	if [[ $PUSH_WHEN_DONE ]]; then
		executeCommand "git push origin :$UNTAG_VERSION"
	fi
	exit 0
elif [[ ! -z $SET_VERSION ]]; then
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
# see if we've got uncommitted changes
#
git diff-index --quiet HEAD -- ; REPO_IS_DIRTY=$?
if [[ $REPO_IS_DIRTY != 0 && -z $STASH_DIRTY_FILES && -z $COMMIT_DIRTY_FILES ]]; then
	exitWithErrorSuggestHelp "You have uncommitted changes in this repo; won't do anything" "(use --stash-dirty-files or --commit-dirty-files to bypass this error)"
fi

confirmationPrompt "Releasing $REPO_NAME $VERSION (current is $CURRENT_VERSION)"

if [[ $REPO_IS_DIRTY && $STASH_DIRTY_FILES ]]; then
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
# build each scheme we can find
#
xcodebuild -list | grep "\s${REPO_NAME}" | grep -v Tests | sort | uniq | sed "s/^[ \t]*//" | while read SCHEME
do
	updateStatus "Building: $SCHEME..."
	executeCommand "$XCODEBUILD -project ${REPO_NAME}.xcodeproj -scheme \"$SCHEME\" -configuration Release clean build $XCODEBUILD_PIPETO"
done

if [[ ! $SKIP_TESTS ]]; then
	xcodebuild -list | grep "\s${REPO_NAME}" | grep UnitTests | sort | uniq | sed "s/^[ \t]*//" | while read TARGET
	do
		SCHEME=$(echo "$TARGET" | sed sqUnitTestsqq)
		updateStatus "Executing unit tests: $TARGET for $SCHEME..."
		executeCommand "$XCODEBUILD -project ${REPO_NAME}.xcodeproj -scheme \"$SCHEME\" -configuration Release clean test $XCODEBUILD_PIPETO"
	done
fi

updateStatus "Adjusting version numbers"
executeCommand "$PLIST_BUDDY \"$FRAMEWORK_PLIST_PATH\" -c \"Set :CFBundleShortVersionString $VERSION\""
executeCommand "agvtool bump"

if [[ ! $SKIP_DOCUMENTATION ]]; then
	updateStatus "Rebuilding documentation"
	executeCommand "$SCRIPT_DIR/generateDocumentationForAPI.sh"
	executeCommand "git add Documentation/."
fi

updateStatus "Committing changes"
BUILD_NUMBER=`agvtool vers -terse`
COMMIT_COMMENT="Release $VERSION (build $BUILD_NUMBER)"
if [[ $REPO_IS_DIRTY && $COMMIT_DIRTY_FILES ]]; then
	COMMIT_COMMENT="$COMMIT_COMMENT -- committed with other changes"
fi
executeCommand "git commit -a -m '$COMMIT_COMMENT'"

updateStatus "Tagging repo for $VERSION release"
executeCommand "git tag -a $VERSION -m 'Release $VERSION issued by $SCRIPT_NAME'"

if [[ $PUSH_WHEN_DONE ]]; then
	updateStatus "Pushing changes to origin"
	executeCommand "git push"
	executeCommand "git push --tags"
fi
