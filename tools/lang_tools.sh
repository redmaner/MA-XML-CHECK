#!/bin/bash
# Copyright (c) 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Variables
COUNT=0
MAX_COUNT=$((4*24*7)) 

#########################################################################################################
# PULL LANGUAGES
#########################################################################################################
pull_lang () {
if [ "$PULL_FLAG" != "" ]; then
	if [ $PULL_FLAG == "force" ]; then
		rm -rf $MAIN_DIR/languages/$LANG_TARGET; sleep 1; sync
	fi
fi
if [ -d $MAIN_DIR/languages/$LANG_TARGET ]; then
	OLD_GIT=$(grep "url = *" $MAIN_DIR/languages/$LANG_TARGET/.git/config | cut -d' ' -f3)
	if [ "$LANG_GIT" != "$OLD_GIT" ]; then
		echo -e "${txtblu}\nNew repository detected, removing old repository...\n$OLD_GIT ---> $LANG_GIT${txtrst}"
		rm -rf $MAIN_DIR/languages/$LANG_TARGET
	fi
fi

echo -e "${txtblu}\nSyncing $LANG_NAME MIUI$LANG_VERSION${txtrst}"
if [ -e $MAIN_DIR/languages/$LANG_TARGET ]; then
     	cd $MAIN_DIR/languages/$LANG_TARGET; git pull origin $LANG_BRANCH 2> $MAIN_DIR/languages/logs/$LANG_TARGET.log; cd ../../..
else
     	git clone $LANG_GIT  -b $LANG_BRANCH $MAIN_DIR/languages/$LANG_TARGET 2> $CACHE/languages/logs/$LANG_TARGET.log
fi
}

# Fix old languages format (trigger with --fix_languages)
fix_lang_folder () {
sync_resources
cat $LANG_XML | grep '<language enabled=' | while read all_line; do
	CHANGE_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
	CHANGE_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
	CHANGE_ISO=$(echo $all_line | awk '{print $5}' | cut -d'"' -f2) 
	if [ -d $MAIN_DIR/languages/$CHANGE_ISO ]; then
		mv $MAIN_DIR/languages/$CHANGE_ISO $MAIN_DIR/languages/"$CHANGE_NAME"_"$CHANGE_VERSION"
	fi
done
}
