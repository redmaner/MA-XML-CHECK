#!/bin/bash
# Copyright (c) 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

#########################################################################################################
# START XML CHECK
#########################################################################################################
init_xml_check () {
if [ -d $MAIN_DIR/languages/$LANG_TARGET ]; then
	echo -e "${txtblu}\nChecking $LANG_NAME MIUI$LANG_VERSION ($LANG_ISO)${txtrst}"
   	rm -f $APK_TARGETS
	debug_mode
	find $MAIN_DIR/languages/$LANG_TARGET -iname "*.apk" | sort | while read apk_target; do
		APK=$(basename $apk_target)
		DIR=$(basename $(dirname $apk_target))
		find $apk_target -iname "arrays.xml*" -o -iname "strings.xml*" -o -iname "plurals.xml*" | while read xml_target; do
			xml_check "$xml_target"
		done
	done
	check_log
fi
}

xml_check () {
XML_TARGET=$1

rm -f $XML_CACHE_LOG
rm -f $XML_LOG_TEMP
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

	case "$LANG_CHECK" in
		normal) xml_check_normal;;
		  full) xml_check_normal; xml_check_full;;
	esac
fi
}

#########################################################################################################
# XML CHECK
#########################################################################################################
xml_check_normal () {
# Check for XML Parser errors
xmllint --noout $XML_TARGET 2>> $XML_CACHE_LOG
write_log

# Check for doubles
if [ "$XML_TYPE" == "strings.xml" ]; then	
	cat $XML_TARGET | grep '<string name=' | cut -d'>' -f1 | cut -d'<' -f2 | sort | uniq --repeated | while read double; do
		grep -ne "$double" $XML_TARGET >> $XML_CACHE_LOG
	done
	write_log_error "orange"
fi
	
# Check for apostrophe errors
grep "<string" $XML_TARGET > $XML_TARGET_STRIPPED
grep -v '>"' $XML_TARGET_STRIPPED > $APOSTROPHE_RESULT
if [ -e $APOSTROPHE_RESULT ]; then
      	grep "'" $APOSTROPHE_RESULT > $XML_TARGET_STRIPPED
      	grep -v "'\''" $XML_TARGET_STRIPPED > $APOSTROPHE_RESULT
       	if [ -e $APOSTROPHE_RESULT ]; then
              	cat $APOSTROPHE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_CACHE_LOG
       	fi
fi
write_log_error "brown"

# Check for '+' at the beginning of a line, outside <string>
grep -ne "+ * <s" $XML_TARGET >> $XML_CACHE_LOG
write_log_error "blue"
}

xml_check_full () {
# Check for untranslateable strings, arrays, plurals using untranslateable list
if [ $(cat $UNTRANSLATEABLE_LIST | grep 'application="'$APK'" file="'$XML_TYPE'"' | wc -l) -gt 0 ]; then
	cat $UNTRANSLATEABLE_LIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'"' | while read all_line; do
		UNTRANSLATEABLE_STRING=$(echo $all_line | awk '{print $5}' | cut -d'/' -f1)
		grep -ne ''$UNTRANSLATEABLE_STRING'' $XML_TARGET
	done >> $XML_CACHE_LOG
	cat $UNTRANSLATEABLE_LIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'"' | while read all_line; do
		UNTRANSLATEABLE_STRING=$(echo $all_line | awk '{print $5}' | cut -d'/' -f1)
		grep -ne ''$UNTRANSLATEABLE_STRING'' $XML_TARGET
	done >> $XML_CACHE_LOG
	if [ "$DIR" != "main" ]; then
		cat $UNTRANSLATEABLE_LIST | grep 'folder="devices" application="'$APK'" file="'$XML_TYPE'"' | while read all_line; do
			UNTRANSLATEABLE_STRING=$(echo $all_line | awk '{print $5}' | cut -d'/' -f1)
			grep -ne ''$UNTRANSLATEABLE_STRING'' $XML_TARGET
		done >> $XML_CACHE_LOG
	fi
fi

# Check for untranslateable strings and arrays due automatically search for @
case "$XML_TYPE" in 
	strings.xml) cat $XML_TARGET | grep '@android\|@string\|@color\|@drawable' | cut -d'>' -f1 | cut -d'"' -f2 | while read auto_search_target; do
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
		     done >> $XML_CACHE_LOG;;
	 arrays.xml) cat $XML_TARGET | grep 'name="' | while read arrays; do
				ARRAY_TYPE=$(echo $arrays | cut -d' ' -f1 | cut -d'<' -f2)
				ARRAY_NAME=$(echo $arrays | cut -d'>' -f1 | cut -d'"' -f2)
				if [ $(arrays_parse $ARRAY_NAME $ARRAY_TYPE $XML_TARGET | grep '@android\|@string\|@color\|@drawable' | wc -l) -gt 0 ]; then
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
		     done >> $XML_CACHE_LOG;;
esac
write_log_error "purple"

# Count array items
if [ "$XML_TYPE" == "arrays.xml" ] && [ "$DIR" == "main" ]; then
	cat $XML_TARGET | grep 'name=' | while read array_count; do
		ARRAY_NAME=$(echo $array_count | cut -d'>' -f1 | cut -d'"' -f2)
		if [ $(cat $ARRAY_ITEM_LIST | grep ''$APK'|'$ARRAY_NAME'|' | wc -l) -gt 0 ]; then
			ARRAY_TYPE=$(echo $array_count | cut -d' ' -f1 | cut -d'<' -f2)
			DIFF_ARRAY_COUNT=$(cat $ARRAY_ITEM_LIST | grep ''$APK'|'$ARRAY_NAME'|' | cut -d'|' -f3)
			TARGET_ARRAY_COUNT=$(arrays_count_items $ARRAY_NAME $ARRAY_TYPE $XML_TARGET)
			if [ "$TARGET_ARRAY_COUNT" != "$DIFF_ARRAY_COUNT" ]; then
				ARRAY=$(grep -ne '"'$ARRAY_NAME'"' $XML_TARGET)
				echo "$ARRAY - has $TARGET_ARRAY_COUNT items, should be $DIFF_ARRAY_COUNT items"
			fi
		fi
	done >> $XML_CACHE_LOG
fi				
write_log_error "teal"
write_log_finish
}

#########################################################################################################
# XML CHECK LOGGING
#########################################################################################################
write_log_error () {
if [ -s $XML_CACHE_LOG ]; then
	echo '</script><span class="'$1'"><script class="error" type="text/plain">' >> $XML_LOG_TEMP
	cat $XML_CACHE_LOG >> $XML_LOG_TEMP
fi
rm -f $XML_CACHE_LOG
}

write_log_finish () {
if [ -s $XML_LOG_TEMP ]; then
	if [ "$DEBUG_MODE" == "double" ]; then
		echo '</script><span class="black"><br>'$XML_TARGET'</span><span class="red"><script class="error" type="text/plain">' >> $XML_LOG_FULL
		cat $XML_LOG_TEMP >> $XML_LOG_FULL
	fi
	echo '</script><span class="black"><br>'$XML_TARGET'</span><span class="red"><script class="error" type="text/plain">' >> $XML_LOG
	cat $XML_LOG_TEMP >> $XML_LOG
fi
rm -f $XML_CACHE_LOG
}

write_log () {
cat $XML_CACHE_LOG >> $XML_LOG_TEMP
rm -f $XML_CACHE_LOG
}
