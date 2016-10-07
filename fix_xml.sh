#!/bin/bash

xml_remove_string () {
STRING_NAME=$1
if [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | wc -l) -gt 0 ]; then
	if [ $DEBUG_FIX == true ]; then
   		echo "Fixing $XML_TARGET"
	fi
	if [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | grep '</string>' | wc -l) -gt 0 ]; then
		sed -e '/<string name="'$STRING_NAME'"/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		AUTO_FIX=true
	elif [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | grep '/>' | wc -l) -gt 0 ]; then
		sed -e '/<string name="'$STRING_NAME'"/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		AUTO_FIX=true
	else
		sed -e '/<string name="'$STRING_NAME'"/,/string>/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		AUTO_FIX=true
	fi
fi
}

xml_remove_array () {
ARRAY_NAME=$1
ARRAY_TYPE=$(cat $XML_TARGET | grep 'name="'$ARRAY_NAME'"' | cut -d'<' -f2 | cut -d' ' -f1)
if [ $(sed -e '/name="'$ARRAY_NAME'"/!d' $XML_TARGET | wc -l) -gt 0 ]; then
	if [ $DEBUG_FIX == true ]; then
   		echo "Fixing $XML_TARGET"
	fi
	case "$ARRAY_TYPE" in
		string-array) 
		sed -e '/name="'$ARRAY_NAME'"/,/string-array/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		AUTO_FIX=true;;

		array) 
		sed -e '/name="'$ARRAY_NAME'"/,/array/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		AUTO_FIX=true;;
	esac
fi
}

xml_fix_untranslateable () {
# Fix untranslateable strings, arrays, plurals using ignorelist
if [ $(cat $IGNORELIST | grep ''$APK' '$XML_TYPE' ' | wc -l) -gt 0 ]; then
	case "$XML_TYPE" in
		arrays.xml)
		cat $IGNORELIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
			init_ignorelist $(cat $IGNORELIST | grep "$all_line")
			xml_remove_array ''$ITEM_NAME''
		done 
		cat $IGNORELIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
			init_ignorelist $(cat $IGNORELIST | grep "$all_line")
			xml_remove_array ''$ITEM_NAME''
		done;;

		strings.xml)
		cat $IGNORELIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
			init_ignorelist $(cat $IGNORELIST | grep "$all_line")
			xml_remove_string ''$ITEM_NAME''
		done 
		cat $IGNORELIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
			init_ignorelist $(cat $IGNORELIST | grep "$all_line")
			xml_remove_string ''$ITEM_NAME''
		done;;
	esac
fi

# Check for untranslateable strings and arrays due automatically search for @
case "$XML_TYPE" in 
	strings.xml) cat $XML_TARGET | grep '@android\|@string\|@color\|@drawable\|@null\|@array' | cut -d'>' -f1 | cut -d'"' -f2 | while read auto_search_target; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$auto_search_target'"/>' | wc -l) == 0 ]; then
					xml_remove_string ''$auto_search_target''; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$auto_search_target'"/>' | wc -l) == 0 ]; then
					xml_remove_string ''$auto_search_target''; continue
				else
					continue
				fi
		     done;;
	 arrays.xml) cat $XML_TARGET | grep 'name="' | while read arrays; do
				ARRAY_TYPE=$(echo $arrays | cut -d'<' -f2 | cut -d' ' -f1)
				ARRAY_NAME=$(echo $arrays | cut -d'>' -f1 | cut -d'"' -f2)
				if [ $(arrays_parse $ARRAY_NAME $ARRAY_TYPE $XML_TARGET | grep '@android\|@string\|@color\|@drawable\|@null\|@array' | wc -l) -gt 0 ]; then
					if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$ARRAY_NAME'"' | wc -l) -eq 0 ]; then
						xml_remove_array ''$ARRAY_NAME''; continue
					else
						continue
					fi
					if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$ARRAY_NAME'"' | wc -l) -eq 0 ]; then
						xml_remove_array ''$ARRAY_NAME''; continue
					else
						continue
					fi
				fi
		     done;;
esac

# Catch values with the values catcher list
if [ $LANG_VERSION -ge 8 ]; then
	case "$XML_TYPE" in
		arrays.xml)
		catch_values_arrays | while read value_entry; do
			cat $XML_TARGET | grep 'name="' | cut -d'"' -f2 | grep "$value_entry" | while read catched_entry; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					xml_remove_array ''$catched_entry''; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					xml_remove_array ''$catched_entry''; continue
				else
					continue
				fi
			done 
		done;;

		strings.xml)
		catch_values_strings | while read value_entry; do
			cat $XML_TARGET | grep 'name="' | cut -d'"' -f2 | grep "$value_entry" | while read catched_entry; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					xml_remove_string ''$catched_entry''; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					xml_remove_string ''$catched_entry''; continue
				else
					continue
				fi
			done 
		done;;
	esac
fi
}
