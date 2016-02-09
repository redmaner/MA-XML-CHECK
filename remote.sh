#!/bin/bash
# Copyright (c) 2013 - 2015, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Variables
REMOTE_GIT="git@github.com:Redmaner/MA-XML-CHECK-REMOTE.git"
REMOTE_BRANCH="master"
LANGUAGE_CONF=$REMOTE_DIR/languages.conf
SYSTEM_CONF=$REMOTE_DIR/system.conf

# Remote tools
remote_log () {
remote_msg=$1
onscreen=$2
pushgit=$3
echo ''$(date +"%m-%d-%Y-%H-%M-%S")' - '$remote_msg'' >> $MAIN_DIR/remote/log
if [ $pushgit == true ]; then
	cd $REMOTE_DIR
	git add system.conf languages.conf log
	git commit -m "$remote_msg"
	git push origin $REMOTE_BRANCH
	cd $MAIN_DIR
fi
if [ $onscreen == true ]; then
	echo -e "${txtblu}\n$remote_msg${txtrst}"
fi
}

remote_update () {
remote_file=$1
remote_cfg=$2
remote_val_old=$3
remote_val_new=$4
cat $remote_file > $remote_file.new
sed 's/'$remote_cfg'='$remote_val_old'/'$remote_cfg'='$remote_val_new'/' $remote_file.new > $remote_file
rm -f $remote_file.new
}

sync_remote () {
echo -e "${txtblu}\nSyncing remote controller${txtrst}"
if [ -d $REMOTE_DIR ]; then
	cd $REMOTE_DIR
	git pull origin $REMOTE_BRANCH
	cd $MAIN_DIR
else
	git clone $REMOTE_GIT -b $REMOTE_BRANCH $REMOTE_DIR
fi
}

check_system_remote () {
if [ "$REMOTE" == true ]; then
	if [ $(cat $SYSTEM_CONF | grep "SYSTEM_UPDATE" | cut -d'=' -f2) == true ]; then
		bash $MAIN_DIR/update.sh
		remote_update $SYSTEM_CONF "SYSTEM_UPDATE" "true" "false"
		remote_log "Updated scripts to the latest version" "false" "true"
		bash $MAIN_DIR/check.sh $1 $2 $3 $4 $5 $6
		exit
	fi
	if [ $(cat $SYSTEM_CONF | grep "LANGUAGE_CONF" | cut -d'=' -f2) == "reset" ]; then
		rm -f $LANGUAGE_CONF
		cat $LANGS_ON | while read language; do
			init_lang $language
			echo "$LANG_TARGET=ok" >> $LANGUAGE_CONF
		done
		remote_update $SYSTEM_CONF "LANGUAGE_CONF" "reset" "false"
		remote_log "Created language.conf" "true" "true"
	fi
fi
}

check_language_remote () {
if [ "$REMOTE" == true ]; then
	if [ "$(cat $LANGUAGE_CONF | grep ''$LANG_TARGET'' | cut -d'=' -f2)" == "wipe" ]; then
		rm -rf $LANG_DIR/$LANG_TARGET
		rm -rf $DATA_DIR/$LANG_TARGET
		remote_update $LANGUAGE_CONF "$LANG_TARGET" "wipe" "ok"
		remote_log "Wiped $LANG_NAME MIUI$LANG_VERSION" "true" "true"
	fi
fi
}

