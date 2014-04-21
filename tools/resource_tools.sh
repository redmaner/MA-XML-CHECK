#!/bin/bash
# Copyright (c) 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Variables
RES_GIT="git@github.com:Redmaner/MA-XML-CHECK-RESOURCES.git"
RES_BRANCH="4.0-dev"
RES_COUNT=$RES_DIR/sync_count
RES_INTERVAL=16

# Sync required resources (languages.xml, ignorelists etc.)
sync_resources () {
echo -e "${txtblu}\nSyncing resources${txtrst}"
if [ "$RES_GIT" != "" ]; then
	if [ -d $RES_DIR/.git ]; then
		OLD_GIT=$(grep "url = *" $RES_DIR/.git/config | cut -d' ' -f3)
		if [ "$RES_GIT" != "$OLD_GIT" ]; then
			echo -e "${txtblu}\nNew resources repository detected, removing old repository...\n$OLD_GIT ---> $RES_GIT${txtrst}"
			rm -rf $RES_DIR
		fi
	fi
	if [ -d $RES_DIR/.git ]; then
		OLD_BRANCH=$(grep 'branch "' $RES_DIR/.git/config | cut -d'"' -f2 | cut -d'[' -f2 | cut -d']' -f1)
		if [ "$RES_BRANCH" != "$OLD_BRANCH" ]; then
			echo -e "${txtblu}\nNew resources branch detected, removing old repository...\n$OLD_BRANCH ---> $RES_BRANCH${txtrst}"
			rm -rf $RES_DIR
		fi
	fi
	if [ -d $RES_DIR ]; then
		cd $RES_DIR
		git pull origin $RES_BRANCH
		cd $MAIN_DIR
	else
		git clone $RES_GIT -b $RES_BRANCH $RES_DIR
	fi
fi

if [ -e $RES_COUNT ]; then
	RES_SYNCS=$(expr $(cat $RES_COUNT) + 1)
	if [ "$RES_SYNCS" == "$RES_INTERVAL" ]; then
		build_resources
		RES_SYNCS=1
	fi
	echo "$RES_SYNCS" > $RES_COUNT
else
	echo "1" > $RES_COUNT
fi
}

build_resources () {
# Pull MIUI-XML-DEV repository, MIUIv6 branch
echo -e "${txtblu}\nSyncing MIUI-XML-DEV, MIUIv6${txtrst}"
if [ -d $RES_DIR/MIUIv6-XML-DEV ]; then
	cd $RES_DIR/MIUIv6-XML-DEV
	git pull origin MIUIv6
	cd $MAIN_DIR
else
	git clone git@github.com:Redmaner/MIUI-XML-DEV.git -b MIUIv6 $RES_DIR/MIUIv6-XML-DEV
fi

# Pull MIUI-XML-DEV repository, MIUIv5 branch
echo -e "${txtblu}\nSyncing MIUI-XML-DEV, MIUIv5${txtrst}"
if [ -d $RES_DIR/MIUIv5-XML-DEV ]; then
	cd $RES_DIR/MIUIv5-XML-DEV
	git pull origin MIUIv5
	cd $MAIN_DIR
else
	git clone git@github.com:Redmaner/MIUI-XML-DEV.git -b MIUIv5 $RES_DIR/MIUIv5-XML-DEV
fi

arrays_count_items_directory $RES_DIR/MIUIv6-XML-DEV/Dev/main MIUIv6_arrays_items.list
arrays_count_items_directory $RES_DIR/MIUIv5-XML-DEV/Dev/main MIUIv5_arrays_items.list

echo -e "${txtblu}\nPushing changes${txtrst}"
cd $RES_DIR
git add MIUIv6_arrays_items.list MIUIv5_arrays_items.list
git commit -m "MA-XML-CHECK: Update array items"
git push origin $RES_BRANCH
cd $MAIN_DIR
}
