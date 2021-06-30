#!/bin/bash
# Copyright (c) 2013 - 2018, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Define bash colors for Mac OSX / Linux
case $(uname -s) in
Darwin)
	txtrst='\033[0m'    # Color off
	txtred='\033[0;31m' # Red
	txtgrn='\033[0;32m' # Green
	txtblu='\033[0;34m' # Blue
	;;

*)
	txtrst='\e[0m'    # Color off
	txtred='\e[1;31m' # Red
	txtgrn='\e[1;32m' # Green
	txtblu='\e[1;36m' # Blue
	;;
esac

# Determine server or a local machine
if [ -d /home/translators.xiaomi.eu ]; then
	MAIN_DIR=/home/translators.xiaomi.eu/scripts
	LOG_DIR=/home/translators.xiaomi.eu/public_html
	REMOTE=true
	MAX_JOBS=4
	INDEX_LOG_HREF="http://translators.xiaomi.eu"
	if [ ! -f $LOG_DIR/xiaomi_europe.png ]; then
		cp $MAIN_DIR/xiaomi_europe.png $LOG_DIR/xiaomi_europe.png
	fi
else
	WDIR="$PWD"; [ "$PWD" = "/" ] && WDIR=""
	case "$0" in
	/*)
		SDIR="${0}"
		;;

	*)
		SDIR="$WDIR/${0#./}"
		;;
	esac

	MAIN_DIR="${SDIR%/*}"

	case "$MAIN_DIR" in
	*\ * )
		echo -e "${txtred}\nError: Script file path must NOT contain spaces\n${txtrst}"
		exit
		;;
	esac

	cd $MAIN_DIR

	LOG_DIR=$MAIN_DIR/logs
	REMOTE=false
	MAX_JOBS=4
	INDEX_LOG_HREF="file://$LOG_DIR"
fi

RES_DIR=$MAIN_DIR/resources
LANG_DIR=$MAIN_DIR/languages
REMOTE_DIR=$MAIN_DIR/remote
DATA_DIR=$MAIN_DIR/data

mkdir -p $LANG_DIR
mkdir -p $LOG_DIR
mkdir -p $DATA_DIR

# Debugging
PRESERVE_CACHE=false
DEBUG_FIX=false

#########################################################################################################
# VARIABLES / CACHE
#########################################################################################################
VERSION=21
DATE=$(date +"%m-%d-%Y-%H-%M-%S")
CACHE="$MAIN_DIR/.cache-$DATE"

# Scripts
ARRAY_TOOLS=$MAIN_DIR/array_tools.sh
RES_TOOLS=$MAIN_DIR/resources.sh
LANG_TOOLS=$MAIN_DIR/repository.sh
CHECK_TOOLS=$MAIN_DIR/check_xml.sh
LOG_TOOLS=$MAIN_DIR/create_log.sh
REMOTE_TOOLS=$MAIN_DIR/remote.sh
FIX_TOOLS=$MAIN_DIR/fix_xml.sh
source $RES_TOOLS
source $REMOTE_TOOLS

# Remote
sync_remote
check_system_remote

#########################################################################################################
# ARGUMENTS
#########################################################################################################
show_argument_help() {
	echo
	echo "MA-XML-CHECK $VERSION"
	echo "By Redmaner"
	echo
	echo "Usage: check.sh [option]"
	echo
	echo " [option]:"
	echo
	echo "		--help						This help"
	echo
	echo "		--pull [all|language] [miuiversion] [force]	Pull all or a specified language"
	echo "								If 'all' is specified, then all languages will be pulled"
	echo "								If a specific language is specified, [miuiversion] must be defined and that language will be pulled"
	echo "								If 'force' is specified as last argument, language(s) will be removed and resynced"
	echo
	echo "		--check [all|language] [miuiversion] [autofix]	Check all or a specified language (do not forget to use '--pull' option first)"
	echo "								If 'all' is specified, then all languages will be checked"
	echo "								If a specific language is specified, [miuiversion] must be defined and that language will be checked"
	echo "								If 'autofix' is specified as last argument, allow pushing an auto-fix commit to language(s) repo(s)"
	echo
	echo "		--clear [cache|logs|all|language]		Removes cache, logs and/or language(s)"
	echo
	exit
}

if [ $# -gt 0 ]; then
	if [ $1 == "--help" ]; then
		show_argument_help

		# Check Languages
	elif [ $1 == "--check" ]; then
		source $ARRAY_TOOLS
		source $LANG_TOOLS
		source $CHECK_TOOLS
		source $LOG_TOOLS
		source $FIX_TOOLS
		sync_resources
		source $RES_DIR/check_mode.sh
		build_cache
		echo
		case "$2" in

		all)
			INDEX_LOGS=true
			cat $LANGS_ON | while read language; do
				init_lang $language
				init_xml_check
				wait
			done
			;;

		*)
			INDEX_LOGS=false
			if [ "$3" == "" ]; then
				echo -e "${txtred}Error: Specifiy MIUI version\n${txtrst}"
				exit
			fi
			if [ "$(cat $LANGS_ALL | grep ''$3' '$2'' | wc -l)" -gt 0 ]; then
				init_lang $(cat $LANGS_ALL | grep ''$3' '$2'')
				rm -f $DATA_DIR/$LANG_TARGET/last_commit
				init_xml_check
			else
				echo -e "${txtred}Error: Language not supported or language not specified\n${txtrst}"
				exit
			fi
			;;
		esac
		wait
		sleep 5
		if [ "${*: -1:1}" == "autofix" ]; then
			check_for_auto_fix
		fi
		make_logs
		if [ $PRESERVE_CACHE == false ]; then
			clear_cache
		fi

		# Pull languages
	elif [ $1 == "--pull" ]; then
		source $LANG_TOOLS
		sync_resources
		case "$2" in

		all)
			cat $LANGS_ON | while read language; do
				if [ "$3" != "" ]; then
					if [ $3 == "force" ]; then
						PULL_FLAG="force"
					fi
				fi
				init_lang $language
				check_language_remote
				pull_lang
			done
			;;

		*)
			if [ "$3" == "" ]; then
				echo -e "${txtred}\nError: Specifiy MIUI version\n${txtrst}"
				exit
			elif [ "$3" == "force" ]; then
				echo -e "${txtred}\nError: Specifiy MIUI version before force flag\n${txtrst}"
				exit
			fi
			if [ "$(cat $LANGS_ALL | grep ''$3' '$2'' | wc -l)" -gt 0 ]; then
				if [ "$4" != "" ]; then
					if [ $4 = "force" ]; then
						PULL_FLAG="force"
					fi
				fi
				init_lang $(cat $LANGS_ALL | grep ''$3' '$2'')
				check_language_remote
				pull_lang
			else
				echo -e "${txtred}\nError: Language not supported or language not specified\n${txtrst}"
				exit
			fi
			;;
		esac

		# Remove stuff
	elif [ $1 == "--clear" ]; then
		if [ "$2" != " " ]; then
			case "$2" in
			logs)
				rm -f $LOG_DIR/XML_*.html
				;;

			cache)
				ls -a | grep ".cache" | while read found_cache; do
					rm -rf $found_cache
				done
				;;

			all)
				rm -rf $MAIN_DIR/languages
				mkdir -p $MAIN_DIR/languages
				rm -rf $DATA_DIR
				;;

			data)
				rm -rf $DATA_DIR
				;;

			*)
				source $LANG_TOOLS
				sync_resources
				if [ "$3" == "" ]; then
					echo -e "${txtred}\nError: Specifiy MIUI version\n${txtrst}"
					exit
				fi
				if [ "$(cat $LANGS_ALL | grep ''$3' '$2'' | wc -l)" -gt 0 ]; then
					init_lang $(cat $LANGS_ALL | grep ''$3' '$2'')
					rm -rf $MAIN_DIR/languages/$LANG_TARGET
				else
					echo -e "${txtred}\nError: Language not supported or language not specified\n${txtrst}"
					exit
				fi
				;;
			esac
		fi

	# Resources
	elif [ $1 == "--resources" ]; then
		if [ "$2" != " " ]; then
			case "$2" in
			sync)
				sync_resources
				;;

			values)
				source $LANG_TOOLS
				sync_resources
				;;

			resync)
				rm -rf $RES_DIR
				sync_resources
				;;

			preparse)
				rm -f $RES_DIR/*.md5
				sync_resources
				;;
			esac
		fi

	# Remote
	elif [ $1 == "--remote" ]; then
		if [ "$2" != " " ]; then
			case "$2" in

			resync)
				rm -rf $REMOTE_DIR
				sync_remote
				;;
			esac
		fi
		exit
	else
		show_argument_help
		exit
	fi
else
	show_argument_help
	exit
fi
