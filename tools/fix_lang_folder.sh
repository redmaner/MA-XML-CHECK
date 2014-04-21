#!/bin/bash
# Copyright (c) 2013 - 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Fix old languages format (trigger with --fix_languages)
clean_up () {
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
