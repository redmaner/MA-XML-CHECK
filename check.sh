#!/bin/bash
# Copyright (c) 2013 - 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Define bash colors for Mac OSX / Linux
case `uname -s` in
    Darwin) 
           txtrst='\033[0m' # Color off
           txtred='\033[0;31m' # Red
           txtgrn='\033[0;32m' # Green
           txtblu='\033[0;34m' # Blue
           ;;
    *)
           txtrst='\e[0m' # Color off
           txtred='\e[1;31m' # Red
           txtgrn='\e[1;32m' # Green
           txtblu='\e[1;36m' # Blue
           ;;
esac

# Determine server or a local machine
if [ -d /home/translators.xiaomi.eu ]; then
     	MAIN_DIR=/home/translators.xiaomi.eu/scripts
     	LOG_DIR=/home/translators.xiaomi.eu/public_html
else
     	MAIN_DIR=$PWD
     	LOG_DIR=$PWD/logs
fi

RES_DIR=$MAIN_DIR/resources
LANG_DIR=$MAIN_DIR/languages

mkdir -p $LANG_DIR
mkdir -p $LOG_DIR

#########################################################################################################
# VARIABLES / CACHE
#########################################################################################################
VERSION=4.3
DATE=$(date +"%m-%d-%Y-%H-%M-%S")
CACHE="$MAIN_DIR/.cache-$DATE"

# Scripts
ARRAY_TOOLS=$MAIN_DIR/array_tools.sh
RES_TOOLS=$MAIN_DIR/resources.sh
LANG_TOOLS=$MAIN_DIR/pull_lang.sh
CHECK_TOOLS=$MAIN_DIR/check_xml.sh
source $RES_TOOLS

#########################################################################################################
# ARGUMENTS
#########################################################################################################
show_argument_help () { 
echo 
echo "MA-XML-CHECK $VERSION"
echo "By Redmaner"
echo 
echo "Usage: check.sh [option]"
echo 
echo " [option]:"
echo " 		--help					This help"
echo "		--check [all|language] [full|double]	Check specified language"
echo "							If all is specified, then all languages will be checked"
echo "							If a specific language is specified, that language will be checked"
echo "							If third argument is not defined, all languages will be logged in seperate files"
echo "							If third argument is 'full', all languages will be logged in one file"
echo "							If third argument is 'double', all languages will be logged in one file and in seperate files"
echo "		--pull [all|language] [force]		Pull specified language"
echo "							If all is specified, then all languages will be pulled"
echo "							If a specific language is specified, that language will be pulled"
echo "							If force is specified, language(s) will be removed and resynced"
echo "		--remove [cache|logs|all|language]	Removes caches, logs or language(s)"
echo 
exit 
}

if [ $# -gt 0 ]; then
     	if [ $1 == "--help" ]; then
          	show_argument_help
     	elif [ $1 == "--check" ]; then
		source $ARRAY_TOOLS; source $CHECK_TOOLS; sync_resources; build_cache
            	DEBUG_MODE=lang
            	case "$2" in
		  	all) if [ "$3" == "double" ]; then
                               	 DEBUG_MODE=double
                             fi; 
			     LINE_NR=$(cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | wc -l)
			     LAST_URL=$(cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | sed -n "$LINE_NR"p | awk '{print $6}' | cut -d'"' -f2)
			     cat $LANGS_ON | while read language; do
					init_lang $language; init_xml_check
   			     done;;
			  *) if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
			     fi
			     if [ "`cat $LANGS_ALL | grep ''$2' '$3''| wc -l`" -gt 0 ]; then
					init_lang $(cat $LANGS_ALL | grep ''$2' '$3''); init_xml_check
                             else
					echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			     fi;;
           	esac		
		clear_cache
     	elif [ $1 == "--pull" ]; then
		source $LANG_TOOLS; sync_resources
            	case "$2" in
			all) cat $LANGS_ON | while read language; do
					if [ "$3" != "" ]; then
   						if [ $3 == "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					init_lang $language; pull_lang
   			     done;;
			  *) if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
			     elif [ "$3" == "force" ]; then
					echo -e "${txtred}\nError: Specifiy MIUI version before force flag${txtrst}"; exit
			     fi
			     if [ "`cat $LANGS_ALL | grep ''$2' '$3''| wc -l`" -gt 0 ]; then
					if [ "$4" != "" ]; then
   						if [ $4 = "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					init_lang $(cat $LANGS_ALL | grep ''$2' '$3''); pull_lang 
                             else
					echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			     fi;;
           	esac
     	elif [ $1 == "--remove" ]; then
            	if [ "$2" != " " ]; then
                 	case "$2" in
                             logs) rm -f $LOG_DIR/XML_*.html;;
			    cache) ls -a | grep ".cache" | while read found_cache; do
					rm -rf $found_cache
				   done;;
                              all) rm -rf $MAIN_DIR/languages; mkdir -p $MAIN_DIR/languages;;
				*) source $LANG_TOOLS; sync_resources
				   if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
				   fi
				   if [ "`cat $LANGS_ALL | grep ''$2' '$3''| wc -l`" -gt 0 ]; then
						init_lang $(cat $LANGS_ALL | grep ''$2' '$3'')
                        			rm -rf $MAIN_DIR/languages/$LANG_TARGET 
                             	   else
						echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			           fi;;
                 	esac 
            	fi
	elif [ $1 == "--resources" ]; then
            	if [ "$2" != " " ]; then
                 	case "$2" in
					sync) sync_resources;;
                        	      resync) rm -rf $RES_DIR; sync_resources;;
                 	esac 
            	fi
     	else
            	show_argument_help; exit
     	fi
else
     	show_argument_help; exit
fi
