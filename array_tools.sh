#!/bin/bash
# Copyright (c) 2013 - 2015, Redmaner
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

#########################################################################################################
# arrays.xml
#########################################################################################################

arrays_count_items_directory () {
TARGET_DIR=$1
ARRAY_COUNT_DIR_LIST=$2

if [ -d $TARGET_DIR ]; then
	echo -e "${txtblu}\nCounting arrays.xml items for all apk folders in $TARGET_DIR${txtrst}"
	rm -f $ARRAY_COUNT_DIR_LIST
	find $TARGET_DIR -iname "*.apk" | sort | while read apk_target; do
		APK=$(basename $apk_target)
		find $apk_target -iname "arrays.xml" | while read array_target; do
			cat $array_target | grep "<string-array name=" | while read all_line; do
				string_array=$(echo $all_line | cut -d'"' -f2 | cut -d'>' -f1)
				item_count=$(sed -e '/name="'$string_array'"/,/string-array/!d' $array_target | grep '<item>' | wc -l)
				echo ''$APK' '$string_array' '$item_count''
			done >> $ARRAY_COUNT_DIR_LIST
			cat $array_target | grep "<array name=" | while read all_line; do
				string_array=$(echo $all_line | cut -d'"' -f2 | cut -d'>' -f1)
				item_count=$(sed -e '/name="'$string_array'"/,/array/!d' $array_target | grep '<item>' | wc -l)
				echo ''$APK' '$string_array' '$item_count''
			done >> $ARRAY_COUNT_DIR_LIST
		done
	done	
fi
}

arrays_count_items () {
TARGET_ARRAY=$1
TARGET_ARRAY_TYPE=$2
TARGET_FILE=$3
case "$TARGET_ARRAY_TYPE" in
	string-array) sed -e '/name="'$TARGET_ARRAY'"/,/string-array/!d' $TARGET_FILE | grep '<item>' | wc -l;;
	array) sed -e '/name="'$TARGET_ARRAY'"/,/array/!d' $TARGET_FILE | grep '<item>' | wc -l;;
esac
}

arrays_parse () {
TARGET_ARRAY=$1
TARGET_ARRAY_TYPE=$2
TARGET_FILE=$3
case "$TARGET_ARRAY_TYPE" in
	string-array) sed -e '/name="'$TARGET_ARRAY'"/,/string-array/!d' $TARGET_FILE;;
	array) sed -e '/name="'$TARGET_ARRAY'"/,/array/!d' $TARGET_FILE;;
esac
}
