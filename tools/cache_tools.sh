#!/bin/bash
# Copyright (c) 2013 - 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

build_cache () {
DATE=$(date +"%m-%d-%Y-%H-%M-%S")
CACHE="$MAIN_DIR/.cache-$DATE"
if [ -d $CACHE ]; then
	case "$SERVER" in
		yes) rm -rf $CACHE; mkdir $CACHE;;
		 no) echo -e "${txtred}ERROR:${TXTRST} $CACHE already exsists\nDo you want to remove the cache? This can interrupt a current check!"
	    	     echo -en "(y,n): "; read cache_remove_awnser
		     if [ $cache_remove_awnser == "y" ]; then
				rm -rf $CACHE; mkdir $CACHE
		     else
				exit
		     fi;;
	esac
else
	rm -rf $CACHE; mkdir $CACHE
fi
XML_TARGET_STRIPPED=$CACHE/xml.target.stripped
APOSTROPHE_RESULT=$CACHE/xml.apostrophe.result
XML_CACHE_LOG=$CACHE/XML_CACHE_LOG
XML_LOG_TEMP=$CACHE/XML_LOG_TEMP
}

clear_cache () {
rm -rf $CACHE
}

clean_cache () {
rm -f $XML_TARGETS_STRIPPED
rm -f $DOUBLE_RESULT
rm -f $OPOSTROPHE_RESULT
rm -f $XML_CACHE_LOG
}
