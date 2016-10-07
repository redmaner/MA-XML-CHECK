#!/bin/bash
# Copyright (c) 2013 - 2015, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

#########################################################################################################
# PULL LANGUAGES
#########################################################################################################
pull_lang () {
if [ "$PULL_FLAG" != "" ]; then
	if [ $PULL_FLAG == "force" ]; then
		rm -rf $DATA_DIR/$LANG_TARGET
		rm -rf $LANG_DIR/$LANG_TARGET; sleep 1; sync
	fi
fi

# Check for new repository ssh
if [ -d $LANG_DIR/$LANG_TARGET ]; then
	OLD_GIT=$(grep "url = *" $LANG_DIR/$LANG_TARGET/.git/config | cut -d' ' -f3)
	if [ "$LANG_GIT" != "$OLD_GIT" ]; then
		echo -e "${txtblu}\nNew repository detected, removing old repository...\n$OLD_GIT ---> $LANG_GIT${txtrst}"
		rm -rf $LANG_DIR/$LANG_TARGET
		rm -rf $DATA_DIR/$LANG_TARGET
	fi
fi

# Pull language
echo -e "${txtblu}\nSyncing $LANG_NAME MIUI$LANG_VERSION${txtrst}"
if [ -e $LANG_DIR/$LANG_TARGET ]; then
     	cd $LANG_DIR/$LANG_TARGET; git pull origin $LANG_BRANCH; cd ../../..
else
     	git clone $LANG_GIT  -b $LANG_BRANCH $LANG_DIR/$LANG_TARGET
fi
}

push_to_repository () {
commit_msg=$1
cd $LANG_DIR/$LANG_TARGET
git add $LANG_NAME
git commit -m "$commit_msg"
git push origin $LANG_BRANCH
cd $MAIN_DIR
}
