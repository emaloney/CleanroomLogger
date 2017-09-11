#!/bin/bash

define()
{
	IFS='\n' read -r -d '' ${1} || true
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

updateStatus()
{
	if [[ ! $QUIET ]]; then
		echo
		echo "$1"
		echo
	fi
}

summarize()
{
	if [[ $SUMMARIZE ]]; then
		printf "\t...%s\n" "$1"
	fi
}

confirmationPrompt()
{
	if [[ ! $QUIET || ! $AUTOMATED_MODE ]]; then
		echo
		echo $1
	fi
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
	unset _CMD
	if [[ $QUIET ]]; then
		_CMD="set -o pipefail && $1 > /dev/null"
	else
		_CMD="set -o pipefail && $1"
	fi
	eval $_CMD
	if [[ $? != 0 ]]; then
		exitWithError "Command failed: $_CMD"
	fi
}

#
# these functions compensate for the fact that macOS is still on bash 3.x
# and therefore a more sensible implementation using associative
# arrays is not currently possible
#
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
	iOS)
		SIMULATOR_ID=`xcrun simctl list | grep -v unavailable | grep "iPad Pro" | grep inch | tail -1 | sed "s/^.*inch) (//" | sed "s/).*$//"`
		echo "id=$SIMULATOR_ID"
		;;

	macOS)
		echo "platform=macOS"
		;;

	tvOS)
		SIMULATOR_ID=`xcrun simctl list | grep -v unavailable | grep "Apple TV" | tail -1 | sed "s/) (.*)\$//" | sed "s/^.*(//"`
		echo "id=$SIMULATOR_ID"
		;;

	watchOS)
		SIMULATOR_ID=`xcrun simctl list | grep -v unavailable | grep -v "Watch:" | grep "Apple Watch Series" | tail -1 | sed "s/) (.*)\$//" | sed "s/^.*(//"`
		echo "id=$SIMULATOR_ID"
		;;

	esac
}
