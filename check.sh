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
	RES_DIR=/home/translators.xiaomi.eu/scripts/resources
	TOOL_DIR=/home/translators.xiaomi.eu/scripts/tools
	SERVER=yes
else
     	MAIN_DIR=$PWD
     	LOG_DIR=$PWD/logs
	RES_DIR=$PWD/resources
	TOOL_DIR=$PWD/tools
	SERVER=no
fi

if [ ! -e $MAIN_DIR/languages ]; then
	mkdir -p $MAIN_DIR/languages
fi

if [ ! -e $LOGDIR ]; then
	mkdir -p $LOGDIR
fi

#########################################################################################################
# VARIABLES / CACHE
#########################################################################################################
VERSION=4.0
LANG_XML=$RES_DIR/languages.xml

# Tools
ARRAY_TOOLS=$TOOL_DIR/array_tools.sh
CACHE_TOOLS=$TOOL_DIR/cache_tools.sh
CHECK_TOOLS=$TOOL_DIR/check_tools.sh
LANG_TOOLS=$TOOL_DIR/lang_tools.sh
RES_TOOLS=$TOOL_DIR/resource_tools.sh

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
		source $ARRAY_TOOLS; source $CACHE_TOOLS; source $CHECK_TOOLS; source $RES_TOOLS
		build_cache
		sync_resources
            	DEBUG_MODE=lang
            	case "$2" in
		  	all) if [ "$3" == "full" ]; then
                                 DEBUG_MODE=full
                             elif [ "$3" == "double" ]; then
                               	 DEBUG_MODE=double
                             fi; 
			     LINE_NR=$(cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | wc -l)
			     LAST_URL=$(cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | sed -n "$LINE_NR"p | awk '{print $6}' | cut -d'"' -f2)
			     cat $LANG_XML | grep '<language check=' | grep -v '<language check="false"' | while read all_line; do
					LANG_CHECK=$(echo $all_line | awk '{print $2}' | cut -d'"' -f2)
					LANG_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
					LANG_ISO=$(echo $all_line | awk '{print $5}' | cut -d'"' -f2)
				      	LANG_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
					LANG_URL=$(echo $all_line | awk '{print $6}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
					UNTRANSLATEABLE_LIST=$RES_DIR/MIUI"$LANG_VERSION"_ignorelist.xml
					ARRAY_ITEM_LIST=$RES_DIR/MIUI"$LANG_VERSION"_arrays_items.list
					AUTO_IGNORELIST=$RES_DIR/MIUI"$LANG_VERSION"_auto_ignorelist.xml
                        		init_xml_check
   			     done;;
			  *) if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
			     fi
			     if [ "`cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"'| wc -l`" -gt 0 ]; then
					LANG_CHECK=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $2}' | cut -d'"' -f2)
					LANG_VERSION=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $3}' | cut -d'"' -f2)
					LANG_ISO=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $5}' | cut -d'"' -f2)
				      	LANG_NAME=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $4}' | cut -d'"' -f2)
					LANG_URL=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $6}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
					UNTRANSLATEABLE_LIST=$RES_DIR/MIUI"$LANG_VERSION"_ignorelist.xml
					ARRAY_ITEM_LIST=$RES_DIR/MIUI"$LANG_VERSION"_arrays_items.list
					AUTO_IGNORELIST=$RES_DIR/MIUI"$LANG_VERSION"_auto_ignorelist.xml
                                 	init_xml_check
                             else
					echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			     fi;;
           	esac
		clear_cache			
     	elif [ $1 == "--pull" ]; then
		source $LANG_TOOLS; source $RES_TOOLS
		sync_resources
            	case "$2" in
			all) cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | while read all_line; do
					if [ "$3" != "" ]; then
   						if [ $3 == "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					LANG_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
					LANG_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
					LANG_GIT=$(echo $all_line | awk '{print $7}' | cut -d'"' -f2)
					LANG_BRANCH=$(echo $all_line | awk '{print $8}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
                        		pull_lang
   			     done;;
			  *) if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
			     elif [ "$3" == "force" ]; then
					echo -e "${txtred}\nError: Specifiy MIUI version before force flag${txtrst}"; exit
			     fi
			     if [ "`cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | wc -l`" -gt 0 ]; then
					if [ "$4" != "" ]; then
   						if [ $4 = "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					LANG_VERSION=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $3}' | cut -d'"' -f2)
					LANG_NAME=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $4}' | cut -d'"' -f2)
					LANG_GIT=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"'| awk '{print $7}' | cut -d'"' -f2)
					LANG_BRANCH=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"'| awk '{print $8}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
                        		pull_lang 
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
				*) source $LANG_TOOLS; source $RES_TOOLS; sync_resources
				   if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
				   fi
				   if [ "`cat $LANG_XML | grep 'name="'$2'"' | 'miui="'$3'"' | wc -l`" -gt 0 ]; then
						LANG_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
						LANG_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
						LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
                        			rm -rf $MAIN_DIR/languages/$LANG_TARGET 
                             	   else
						echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			           fi;;
                 	esac 
            	fi
     	elif [ $1 == "--fix_languages" ]; then
		source $LANG_TOOLS; fix_lang_folder
     	else
            	show_argument_help; exit
     	fi
else
     	show_argument_help; exit
fi
