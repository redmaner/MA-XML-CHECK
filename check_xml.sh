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
	mkdir -p $CACHE/$LANG_TARGET.cached
	echo "$LANG_NAME" > $CACHE/$LANG_TARGET.cached/lang_name
	echo "$LANG_VERSION" > $CACHE/$LANG_TARGET.cached/lang_version
	DATESTAMP=$(date +"%m-%d-%Y %H:%M:%S")
	echo "$DATESTAMP" > $CACHE/$LANG_TARGET.cached/datestamp
	for apk_target in $(find $LANG_DIR/$LANG_TARGET -iname "*.apk" | sort); do
		APK=$(basename $apk_target)
		DIR=$(basename $(dirname $apk_target))
		for xml_target in $(find $apk_target -iname "arrays.xml*" -o -iname "strings.xml*" -o -iname "plurals.xml*"); do
			xml_check "$xml_target" &
		done
	done
fi
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

	case "$LANG_CHECK" in
		basic) 
		max_proces; xml_check_parser &
		max_proces; xml_check_doubles &
		max_proces; xml_check_apostrophe &
		max_proces; xml_check_values &
		max_proces; xml_check_plus &
		max_proces; xml_check_variables &;;

		normal) 
		max_proces; xml_check_parser &
		max_proces; xml_check_doubles &
		max_proces; xml_check_apostrophe &
		max_proces; xml_check_values &
		max_proces; xml_check_plus &
		max_proces; xml_check_variables &
		max_proces; xml_check_untranslateable &;;

		other)
		max_proces; xml_check_parser &
		max_proces; xml_check_doubles &
		max_proces; xml_check_apostrophe &
		max_proces; xml_check_plus &
		max_proces; xml_check_variables &;;
	esac
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

xml_check_untranslateable () {
# Check for untranslateable strings, arrays, plurals using ignorelist
XML_LOG_UNTRANSLATEABLE=$FILE_CACHE/UNTRANSLATEABLE.log
if [ $(cat $IGNORELIST | grep ''$APK' '$XML_TYPE' ' | wc -l) -gt 0 ]; then
	cat $IGNORELIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
		init_ignorelist $(cat $IGNORELIST | grep "$all_line")
		grep -ne '"'$ITEM_NAME'"' $XML_TARGET
	done >> $XML_LOG_UNTRANSLATEABLE
	cat $IGNORELIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
		init_ignorelist $(cat $IGNORELIST | grep "$all_line")
		grep -ne '"'$ITEM_NAME'"' $XML_TARGET
	done >> $XML_LOG_UNTRANSLATEABLE
	if [ "$DIR" != "main" ]; then
		cat $IGNORELIST | grep 'devices '$APK' '$XML_TYPE' ' | while read all_line; do
			init_ignorelist $(cat $IGNORELIST| grep "$all_line")
			grep -ne '"'$ITEM_NAME'"' $XML_TARGET
		done >> $XML_LOG_UNTRANSLATEABLE
	fi
fi

# Check for untranslateable strings and arrays due automatically search for @
case "$XML_TYPE" in 
	strings.xml) cat $XML_TARGET | grep '@android\|@string\|@color\|@drawable\|@null\|@string\|@array' | cut -d'>' -f1 | cut -d'"' -f2 | while read auto_search_target; do
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
				if [ "$DIR" != "main" ]; then
					if [ $(cat $AUTO_IGNORELIST | grep 'folder="devices" application="'$APK'" file="'$XML_TYPE'" name="'$auto_search_target'"/>' | wc -l) == 0 ]; then
						grep -ne '"'$auto_search_target'"' $XML_TARGET
					fi
				fi
		     done >> $XML_LOG_UNTRANSLATEABLE;;
	 arrays.xml) cat $XML_TARGET | grep 'name="' | while read arrays; do
				ARRAY_TYPE=$(echo $arrays | cut -d' ' -f1 | cut -d'<' -f2)
				ARRAY_NAME=$(echo $arrays | cut -d'>' -f1 | cut -d'"' -f2)
				if [ $(arrays_parse $ARRAY_NAME $ARRAY_TYPE $XML_TARGET | grep '@android\|@string\|@color\|@drawable\|@null\|@string\|@array' | wc -l) -gt 0 ]; then
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
					if [ "$DIR" != "main" ]; then
						if [ $(cat $AUTO_IGNORELIST | grep 'folder="devices" application="'$APK'" file="'$XML_TYPE'" name="'$ARRAY_NAME'"' | wc -l) -eq 0 ]; then
							grep -ne '"'$ARRAY_NAME'"' $XML_TARGET
						fi
					fi
				fi
		     done >> $XML_LOG_UNTRANSLATEABLE;;
esac
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
