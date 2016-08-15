#!/bin/bash

set -e

SCRIPT_NAME=`basename $0`
SCRIPT_DIR=`dirname "$PWD/$0"`

PROJECT_DIR="$SCRIPT_DIR/../.."

if [[ ! -e "$PROJECT_DIR/.git" ]]; then
	echo "error: Expected to find git project at: $PROJECT_DIR"
	exit 1
fi

#
# parse the command-line arguments
#
while [[ $1 ]]; do
	case $1 in
	--create|-c)
		CREATE_BRANCH=1
		;;
	
	--fetch|-f)
		PULL_BRANCH=1
		;;
	
	--merge|-m)
		MERGE_BRANCH=1
		;;
	
	--pull|-p)
		PULL_BRANCH=1
		;;
	
	--no-track)
		DONT_TRACK_REMOTE=1
		;;
	
# 	--help|-h|-\?)
# 		SHOW_HELP=1
# 		;;
		
	-*)
		echo "error: Unrecognized argument: $1"
		exit 2
		;;
		
	*)
		if [[ -z $BRANCH ]]; then
			BRANCH=$1		
		else
			echo "error: Branch already specified: $BRANCH"
			exit 2
		fi
	esac
	shift
done

if [[ -z $BRANCH ]]; then
	echo "error: Expected branch name as argument"
	exit 2
fi

if [[ $FETCH_BRANCH && $MERGE_BRANCH ]]; then
	unset FETCH_BRANCH
	unset MERGE_BRANCH
	PULL_BRANCH=1
fi

if [[ $CREATE_BRANCH && ( $FETCH_BRANCH || $MERGE_BRANCH || $PULL_BRANCH ) ]]; then
	echo "error: --create (-c) cannot be used with --fetch (-f), --merge (-m), or --pull (-p)"
	exit 2
fi

if [[ $DONT_TRACK_REMOTE && !$CREATE_BRANCH ]]; then
	echo "error: --no-track may only be used in conjunction with --create (-c)"
	exit 2
fi

cd "$PROJECT_DIR"
PROJECT_NAME=`basename $PWD`

if [[ $CREATE_BRANCH ]]; then
	echo "Recursively creating $BRANCH branch in all $PROJECT_NAME submodules:"
	if [[ $DONT_TRACK_REMOTE ]]; then
		git submodule foreach --recursive git checkout --no-track -b "$BRANCH"
	else
		git submodule foreach --recursive git checkout --track -b "$BRANCH"
	fi
else
	echo "Recursively checking out $BRANCH branch in all $PROJECT_NAME submodules:"
	git submodule foreach --recursive git checkout "$BRANCH"
	if [[ $PULL_BRANCH ]]; then
		echo "Recursively pulling $BRANCH branch in all $PROJECT_NAME submodules:"
		git submodule foreach --recursive git pull origin "$BRANCH"
	elif [[ $FETCH_BRANCH ]]; then
		echo "Recursively fetching $BRANCH branch in all $PROJECT_NAME submodules:"
		git submodule foreach --recursive git fetch origin "$BRANCH"
	elif [[ $MERGE_BRANCH ]]; then
		echo "Recursively merging $BRANCH branch in all $PROJECT_NAME submodules:"
		git submodule foreach --recursive git merge "$BRANCH"
	fi		
fi
