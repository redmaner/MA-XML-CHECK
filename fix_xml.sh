#!/bin/bash
# Copyright (c) 2013 - 2018, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Remove string function
xml_remove_string () {
STRING_NAME=$1
if [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | wc -l) -gt 0 ]; then
	if [ $DEBUG_FIX == true ]; then
   		echo "Fixing $XML_TARGET"
	fi
	if [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | grep '</string>' | wc -l) -gt 0 ]; then
		sed -e '/<string name="'$STRING_NAME'"/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		write_auto_fix
	elif [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | grep '/>' | wc -l) -gt 0 ]; then
		sed -e '/<string name="'$STRING_NAME'"/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		write_auto_fix
	else
		sed -e '/<string name="'$STRING_NAME'"/,/string>/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		write_auto_fix
	fi
fi
}

# Remove string function specifically for removing doubles
xml_remove_string_double () {
STRING_NAME=$1
if [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | wc -l) -gt 0 ]; then
	if [ $DEBUG_FIX == true ]; then
   		echo "Fixing $XML_TARGET"
	fi
	if [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | grep '</string>' | wc -l) -gt 0 ]; then
		sed -e '0,/'$STRING_NAME'/{/<string name="'$STRING_NAME'"/d}' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		write_auto_fix
	elif [ $(sed -e '/name="'$STRING_NAME'"/!d' $XML_TARGET | grep '/>' | wc -l) -gt 0 ]; then
		sed -e '0,/'$STRING_NAME'/{/<string name="'$STRING_NAME'"/d}' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		write_auto_fix
	else
		sed -e '/<string name="'$STRING_NAME'"/,/string>/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
		write_auto_fix
	fi
fi
}

# Remove array function
xml_remove_array () {
ARRAY_NAME=$1
ARRAY_TYPE=$(cat $XML_TARGET | grep 'name="'$ARRAY_NAME'"' | cut -d'<' -f2 | cut -d' ' -f1)
if [ $(sed -e '/name="'$ARRAY_NAME'"/!d' $XML_TARGET | wc -l) -gt 0 ]; then
	if [ $DEBUG_FIX == true ]; then
   		echo "Fixing $XML_TARGET"
	fi
	sed -e '/name="'$ARRAY_NAME'"/,/'$ARRAY_TYPE'/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
	write_auto_fix
fi
}

xml_remove_array_double () {
ARRAY_NAME=$1
ARRAY_TYPE=$(cat $XML_TARGET | grep 'name="'$ARRAY_NAME'"' | cut -d'<' -f2 | cut -d' ' -f1 | uniq)
if [ $(sed -e '/name="'$ARRAY_NAME'"/!d' $XML_TARGET | wc -l) -gt 0 ]; then
	if [ $DEBUG_FIX == true ]; then
   		echo "Fixing $XML_TARGET"
	fi
	sed -e '/name="'$ARRAY_NAME'"/,/'$ARRAY_TYPE'/d' $XML_TARGET >> $XML_TARGET.fixed; mv $XML_TARGET.fixed $XML_TARGET
	write_auto_fix
fi
}

write_auto_fix () {
echo "Auto fixed" > $CACHE/$LANG_TARGET.cached/$LANG_TARGET.fixed
}

check_for_auto_fix () {
find $CACHE -iname "*.fixed" | while read fixed_lang; do
	CACHED_FIX=$(dirname $fixed_lang)
	init_lang $(cat $LANGS_ALL | grep ''$(cat $CACHED_FIX/lang_version)' '$(cat $CACHED_FIX/lang_name)'');
	push_to_repository "Auto fixes by translators.xiaomi.eu"
done
}

# Remove doubles
xml_fix_double () {
case "$XML_TYPE" in

	strings.xml)	
	cat $XML_TARGET | grep '<string name=' | cut -d'"' -f2 | sort | uniq --repeated | while read double; do
		xml_remove_string_double ''$double''
	done;;

	arrays.xml)
	cat $XML_TARGET | grep 'name=' | cut -d'"' -f2 | sort | uniq --repeated | while read double; do
		xml_remove_array_double ''$double''
	done;;

esac
}

xml_fix_untranslateable () {
# Fix untranslateable strings, arrays, plurals using ignorelist
if [ $(cat $UNTRANSLATEABLE_LIST | grep ''$APK' '$XML_TYPE' ' | wc -l) -gt 0 ]; then
	case "$XML_TYPE" in
		arrays.xml)
		cat $UNTRANSLATEABLE_LIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
			init_list $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
			xml_remove_array ''$ITEM_NAME''
		done 
		cat $UNTRANSLATEABLE_LIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
			init_list $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
			xml_remove_array ''$ITEM_NAME''
		done;;

		strings.xml)
		cat $UNTRANSLATEABLE_LIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
			init_list $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
			xml_remove_string ''$ITEM_NAME''
		done 
		cat $UNTRANSLATEABLE_LIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
			init_list $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
			xml_remove_string ''$ITEM_NAME''
		done;;
	esac
fi

# Check for untranslateable strings and arrays due automatically search for @
case "$XML_TYPE" in 

	strings.xml) 
	cat $XML_TARGET | grep '@android\|@string\|@color\|@drawable\|@null\|@array' | cut -d'>' -f1 | cut -d'"' -f2 | while read auto_search_target; do
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

	arrays.xml)
	cat $XML_TARGET | grep 'name="' | while read arrays; do
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
if [ -e $VALUE_CATCHER_LIST ]; then
	if [ $(cat $VALUE_CATCHER_LIST | grep ''$APK' '$XML_TYPE' ' | wc -l) -gt 0 ]; then
		case "$XML_TYPE" in
			arrays.xml)
			cat $VALUE_CATCHER_LIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
				init_list $(cat $VALUE_CATCHER_LIST | grep "$all_line")
				xml_remove_array ''$ITEM_NAME''
			done 
			cat $VALUE_CATCHER_LIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
				init_list $(cat $VALUE_CATCHER_LIST | grep "$all_line")
				xml_remove_array ''$ITEM_NAME''
			done;;

			strings.xml)
			cat $VALUE_CATCHER_LIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
				init_list $(cat $VALUE_CATCHER_LIST | grep "$all_line")
				xml_remove_string ''$ITEM_NAME''
			done 
			cat $VALUE_CATCHER_LIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
				init_list $(cat $VALUE_CATCHER_LIST | grep "$all_line")
				xml_remove_string ''$ITEM_NAME''
			done;;
		esac
	fi
fi
}
