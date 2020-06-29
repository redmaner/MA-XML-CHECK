#!/bin/bash
# Copyright (c) 2013 - 2018, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

#########################################################################################################
# CACHING
#########################################################################################################
build_cache () {
  rm -rf $CACHE; mkdir $CACHE
}

clear_cache () {
  wait
  rm -rf $CACHE
}

#########################################################################################################
# START XML CHECK
#########################################################################################################
init_xml_check () {
	if [ -d $LANG_DIR/$LANG_TARGET ]; then
		echo -e "${txtblu}Checking $LANG_NAME MIUI$LANG_VERSION ($LANG_ISO)${txtrst}"
		mkdir -p $DATA_DIR/$LANG_TARGET
		mkdir -p $CACHE/$LANG_TARGET.cached
		echo "$LANG_NAME" > $CACHE/$LANG_TARGET.cached/lang_name
		echo "$LANG_VERSION" > $CACHE/$LANG_TARGET.cached/lang_version
		DATESTAMP=$(date +"%a %d %b %Y %H:%M:%S")
		echo "$DATESTAMP" > $CACHE/$LANG_TARGET.cached/datestamp
		if [ -f $DATA_DIR/$LANG_TARGET/last_commit ]; then
			if [ $(cat $DATA_DIR/$LANG_TARGET/last_commit) == $(cat $LANG_DIR/$LANG_TARGET/.git/refs/heads/$LANG_BRANCH) ]; then
				if [ -f $DATA_DIR/$LANG_TARGET/prev_log ]; then
					echo ">>> Repository is not changed, using old log"
					cp $DATA_DIR/$LANG_TARGET/prev_log $CACHE/$LANG_TARGET.cached/prev_log
					cp $DATA_DIR/$LANG_TARGET/datestamp $CACHE/$LANG_TARGET.cached/datestamp
				else
					echo ">>> Repository is not changed, old log not found"
					do_xml_check; wait
					if [ $LANG_FIX != "none" ]; then
						 do_xml_fix
					fi
				fi
			else
				echo ">>> Repository is changed"
				cp $LANG_DIR/$LANG_TARGET/.git/refs/heads/$LANG_BRANCH $DATA_DIR/$LANG_TARGET/last_commit
				do_xml_check; wait
				if [ $LANG_FIX != "none" ]; then
					do_xml_fix
				fi
			fi
		else
			cp $LANG_DIR/$LANG_TARGET/.git/refs/heads/$LANG_BRANCH $DATA_DIR/$LANG_TARGET/last_commit
			do_xml_check; wait
			if [ $LANG_FIX != "none" ]; then
				do_xml_fix
			fi
		fi
	fi
}

do_xml_check () {
	find $LANG_DIR/$LANG_TARGET -iname "*.apk" | sort | while read apk_target; do
			APK=$(basename $apk_target)
			DIR=$(basename $(dirname $apk_target))
			find $apk_target -iname "arrays.xml*" -o -iname "strings.xml*" -o -iname "plurals.xml*" | sort | while read xml_target; do
					xml_check "$xml_target" &
			done
	done
	wait
}

max_proces() {
	while [ $(jobs | wc -l) -gt $MAX_JOBS ]; do
		sleep 1;
	done
}

xml_check () {
	XML_TARGET=$1

	if [ -e "$XML_TARGET" ]; then
		XML_TYPE=$(basename $XML_TARGET)

		VALUES=$(basename $(dirname $XML_TARGET))
		FILE_CACHE=$CACHE/$LANG_TARGET.cached/$DIR-$APK-$VALUES-$XML_TYPE
		mkdir -p $FILE_CACHE
		XML_LOG_TEMP=$FILE_CACHE/XML_LOG_TEMP
		echo "$XML_TARGET" > $FILE_CACHE/XML_TARGET

		# Fix .part files for XML_TYPE
		if [ $(echo $XML_TYPE | grep ".part" | wc -l) -gt 0 ]; then
			case "$XML_TYPE" in
			   	strings.xml.part) XML_TYPE="strings.xml";;
				arrays.xml.part) XML_TYPE="arrays.xml";;
				plurals.xml.part) XML_TYPE="plurals.xml";;
			esac
		fi

		
   		max_proces; xml_check_parser &
    		max_proces; xml_check_values &
    		max_proces; xml_check_variables &
	fi
}

#########################################################################################################
# XML CHECK
#########################################################################################################
xml_check_parser () {
	# Check for XML Parser errors
	XML_LOG_PARSER=$FILE_CACHE/PARSER.log
	xmllint --noout $XML_TARGET 2>> $XML_LOG_PARSER
	write_log_error "red" "$XML_LOG_PARSER"
	if [ ! -s $XML_LOG_PARSER ]; then
	  echo "ok" > $CACHE/$LANG_TARGET.cached/parser.ok
	fi
}


xml_check_values () {
	# Check if values folder is correct
	XML_LOG_VALUES=$FILE_CACHE/VALUES.log
	VALUES_TARGET_XML=$(basename $(dirname $XML_TARGET))
	if [ "$VALUES_TARGET_XML" == 'values' ]; then
		echo "Wrong values folder, should be values-$LANG_ISO" >> $XML_LOG_VALUES
	fi
	write_log_error "cyan" "$XML_LOG_VALUES"
}

xml_check_variables () {
	# Check invalid variable formatting e.g. % s instead of %s
	XML_LOG_VARIABLES=$FILE_CACHE/variables.log
	grep -ne ' 1 $ s \| % s \| % 1 $ s \| % 2 $ s \| % 3 $ s \| % 4 $ s \| % 5 $ s \| % d \| % 1 $ d \| % 2 $ d \| % 3 $ d \| % 4 $ d \| % 5 $ d ' $XML_TARGET >> $XML_LOG_VARIABLES
	grep -ne '(1 $ s)\|(% s)\|(% 1 $ s)\|(% 2 $ s)\|( % 3 $ s)\|(% 4 $ s)\|(% 5 $ s)\|(% d)\|(% 1 $ d)\|(% 2 $ d)\|(% 3 $ d)\|(% 4 $ d)\|(% 5 $ d)' $XML_TARGET >> $XML_LOG_VARIABLES
	write_log_error "grey" "$XML_LOG_VARIABLES"
}

#########################################################################################################
# XML CHECK LOGGING
#########################################################################################################
write_log_error () {
	if [ -s $2 ]; then
		echo '</script><span class="'$1'"><script class="error" type="text/plain">' >> $XML_LOG_TEMP
		cat $2 >> $XML_LOG_TEMP
	fi
	rm -f $2
}
