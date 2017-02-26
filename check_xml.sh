#!/bin/bash
# Copyright (c) 2013 - 2016, Redmaner
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
				if [ $LANG_FIX != "none" ]; then
					do_xml_check true; wait; sync
				fi
				do_xml_check false
			fi
		else
			echo ">>> Repository is changed"
			cp $LANG_DIR/$LANG_TARGET/.git/refs/heads/$LANG_BRANCH $DATA_DIR/$LANG_TARGET/last_commit
			if [ $LANG_FIX != "none" ]; then
				do_xml_check true; wait; sync
			fi
			do_xml_check false
		fi
	else
		cp $LANG_DIR/$LANG_TARGET/.git/refs/heads/$LANG_BRANCH $DATA_DIR/$LANG_TARGET/last_commit
		if [ $LANG_FIX != "none" ]; then
			do_xml_check true; wait; sync
		fi
		do_xml_check false
	fi
fi
}

do_xml_check () {
FIX_MODE=$1
if [ $FIX_MODE == true ]; then
	echo ">>> Fixing repostory"
else 
	echo ">>> Checking repository"
fi

for apk_target in $(find $LANG_DIR/$LANG_TARGET -iname "*.apk" | sort); do
	APK=$(basename $apk_target)
	DIR=$(basename $(dirname $apk_target))
	for xml_target in $(find $apk_target -iname "arrays.xml*" -o -iname "strings.xml*" -o -iname "plurals.xml*"); do
		if [ $FIX_MODE == true ]; then
			xml_fix "$xml_target" &
		else 
			xml_check "$xml_target" &
		fi
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

	$LANG_CHECK
fi
}

xml_fix () {
XML_TARGET=$1

if [ -e "$XML_TARGET" ]; then
	XML_TYPE=$(basename $XML_TARGET)

	# Fix .part files for XML_TYPE
	if [ $(echo $XML_TYPE | grep ".part" | wc -l) -gt 0 ]; then
		case "$XML_TYPE" in
		   	strings.xml.part) XML_TYPE="strings.xml";;
			arrays.xml.part) XML_TYPE="arrays.xml";;
			plurals.xml.part) XML_TYPE="plurals.xml";;
		esac
	fi

	$LANG_FIX
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
}

xml_check_doubles () {
# Check for doubles
XML_LOG_DOUBLES=$FILE_CACHE/DOUBLES.log
case "$XML_TYPE" in
	strings.xml)	
	cat $XML_TARGET | grep '<string name=' | cut -d'>' -f1 | cut -d'<' -f2 | sort | uniq --repeated | while read double; do
		grep -ne "$double" $XML_TARGET >> $XML_LOG_DOUBLES
	done
	write_log_error "orange" "$XML_LOG_DOUBLES";;

	arrays.xml)
	cat $XML_TARGET | grep '<array\|<string-array\|<integer-array' | cut -d'>' -f1 | cut -d'<' -f2 | sort | uniq --repeated | while read double; do
		grep -ne "$double" $XML_TARGET >> $XML_LOG_DOUBLES
	done
	write_log_error "orange" "$XML_LOG_DOUBLES";;

	plurals.xml)
	cat $XML_TARGET | grep '<plurals name=' | cut -d'>' -f1 | cut -d'<' -f2 | sort | uniq --repeated | while read double; do
		grep -ne "$double" $XML_TARGET >> $XML_LOG_DOUBLES
	done
	write_log_error "orange" "$XML_LOG_DOUBLES";;
esac
}
	
xml_check_apostrophe () {
# Check for apostrophe errors
XML_LOG_APOSTROPHE=$FILE_CACHE/APOSTROPHE.log
case "$XML_TYPE" in
	strings.xml)
	
	grep "'" $XML_TARGET | grep '<string' | grep -v '>"' | grep -v "'\''" | while read apostrophe; do
		grep -ne "$apostrophe" $XML_TARGET >> $XML_LOG_APOSTROPHE
	done;;
	*)
	grep "'" $XML_TARGET | grep '<item' | grep -v '>"' | grep -v "'\''" | while read apostrophe; do
		grep -ne "$apostrophe" $XML_TARGET >> $XML_LOG_APOSTROPHE
	done;;
esac

#check for &apos; which is not allowed
grep '&apos;' $XML_TARGET | while read apostrophe; do
	grep -ne "$apostrophe" $XML_TARGET >> $XML_LOG_APOSTROPHE
done

write_log_error "brown" "$XML_LOG_APOSTROPHE"
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

xml_check_plus () {
# Check for '+' at the beginning of a line, outside <string>
XML_LOG_PLUS=$FILE_CACHE/PLUS.log
grep -ne "+ * <s" $XML_TARGET >> $XML_LOG_PLUS
write_log_error "blue" "$XML_LOG_PLUS"
}

xml_check_variables () {
# Check invalid variable formatting e.g. % s instead of %s
XML_LOG_VARIABLES=$FILE_CACHE/variables.log
grep -ne ' 1 $ s \| % s \| % 1 $ s \| % 2 $ s \| % 3 $ s \| % 4 $ s \| % 5 $ s \| % d \| % 1 $ d \| % 2 $ d \| % 3 $ d \| % 4 $ d \| % 5 $ d ' $XML_TARGET >> $XML_LOG_VARIABLES
grep -ne '(1 $ s)\|(% s)\|(% 1 $ s)\|(% 2 $ s)\|( % 3 $ s)\|(% 4 $ s)\|(% 5 $ s)\|(% d)\|(% 1 $ d)\|(% 2 $ d)\|(% 3 $ d)\|(% 4 $ d)\|(% 5 $ d)' $XML_TARGET >> $XML_LOG_VARIABLES
write_log_error "grey" "$XML_LOG_VARIABLES"
}

xml_check_formatted_false () {
XML_LOG_FORMATTED=$FILE_CACHE/formatted.log
# Check if formatted=false is required for same variables in a string
grep "%s\|%d" $XML_TARGET | grep -v 'formatted="false"' | sed -e '/string name="/!d' | cut -d'"' -f2 | uniq --unique | while read string_name; do

	formatted_string=$(sed -e '/name="'$string_name'"/!d' $XML_TARGET)
	formatted_string_plus=$(sed -e '/<string name="'$string_name'"/,/string>/!d' $XML_TARGET)

	if [ $(echo $formatted_string | grep '</string>\|/>' | wc -l) -gt 0 ]; then
		if [ $(echo $formatted_string | grep -o "%s" | wc -l) -ge "2" ]; then
			grep -ne "$string_name" $XML_TARGET >> $XML_LOG_FORMATTED
		fi
		if [ $(echo $formatted_string | grep -o "%d" | wc -l) -ge "2" ]; then
			grep -ne "$string_name" $XML_TARGET >> $XML_LOG_FORMATTED
		fi
	else
		if [ $(echo $formatted_string_plus | grep -o "%s" | wc -l) -ge "2" ]; then
			grep -ne "$string_name" $XML_TARGET >> $XML_LOG_FORMATTED
		fi
		if [ $(echo $formatted_string_plus | grep -o "%d" | wc -l) -ge "2" ]; then
			grep -ne "$string_name" $XML_TARGET >> $XML_LOG_FORMATTED
		fi
	fi
done
write_log_error "gold" "$XML_LOG_FORMATTED"
}

xml_check_untranslateable () {
# Check for untranslateable strings, arrays, plurals using untranslateablelist
XML_LOG_UNTRANSLATEABLE=$FILE_CACHE/UNTRANSLATEABLE.log
if [ $(cat $UNTRANSLATEABLE_LIST | grep ''$APK' '$XML_TYPE' ' | wc -l) -gt 0 ]; then
	cat $UNTRANSLATEABLE_LIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
		init_list $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
		grep -ne '"'$ITEM_NAME'"' $XML_TARGET
	done >> $XML_LOG_UNTRANSLATEABLE
	cat $UNTRANSLATEABLE_LIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
		init_list $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
		grep -ne '"'$ITEM_NAME'"' $XML_TARGET
	done >> $XML_LOG_UNTRANSLATEABLE
fi

# Check for untranslateable strings and arrays due automatically search for @
case "$XML_TYPE" in 
	strings.xml) cat $XML_TARGET | grep '@android\|@string\|@color\|@drawable\|@null\|@array' | cut -d'>' -f1 | cut -d'"' -f2 | while read auto_search_target; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$auto_search_target'"/>' | wc -l) == 0 ]; then
					grep -ne '"'$auto_search_target'"' $XML_TARGET; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$auto_search_target'"/>' | wc -l) == 0 ]; then
					grep -ne '"'$auto_search_target'"' $XML_TARGET; continue
				else
					continue
				fi
		     done >> $XML_LOG_UNTRANSLATEABLE;;
	 arrays.xml) cat $XML_TARGET | grep 'name="' | while read arrays; do
				ARRAY_TYPE=$(echo $arrays | cut -d' ' -f1 | cut -d'<' -f2)
				ARRAY_NAME=$(echo $arrays | cut -d'>' -f1 | cut -d'"' -f2)
				if [ $(arrays_parse $ARRAY_NAME $ARRAY_TYPE $XML_TARGET | grep '@android\|@string\|@color\|@drawable\|@null\|@array' | wc -l) -gt 0 ]; then
					if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$ARRAY_NAME'"' | wc -l) -eq 0 ]; then
						grep -ne '"'$ARRAY_NAME'"' $XML_TARGET; continue
					else
						continue
					fi
					if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$ARRAY_NAME'"' | wc -l) -eq 0 ]; then
						grep -ne '"'$ARRAY_NAME'"' $XML_TARGET; continue
					else
						continue
					fi
				fi
		     done >> $XML_LOG_UNTRANSLATEABLE;;
esac

# Catch values with the values catcher list
if [ $LANG_VERSION -ge 8 ]; then
	case "$XML_TYPE" in
		arrays.xml)
		catch_values_arrays | while read value_entry; do
			cat $XML_TARGET | grep 'name="' | cut -d'"' -f2 | grep "$value_entry" | while read catched_entry; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					grep -ne '"'$catched_entry'"' $XML_TARGET; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					grep -ne '"'$catched_entry'"' $XML_TARGET; continue
				else
					continue
				fi
			done >> $XML_LOG_UNTRANSLATEABLE
		done;;

		strings.xml)
		catch_values_strings | while read value_entry; do
			cat $XML_TARGET | grep 'name="' | cut -d'"' -f2 | grep "$value_entry" | while read catched_entry; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					grep -ne '"'$catched_entry'"' $XML_TARGET; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					grep -ne '"'$catched_entry'"' $XML_TARGET; continue
				else
					continue
				fi
			done >> $XML_LOG_UNTRANSLATEABLE
		done;;
	esac
fi

write_log_error "pink" "$XML_LOG_UNTRANSLATEABLE"
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
