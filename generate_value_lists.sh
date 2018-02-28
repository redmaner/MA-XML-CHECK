#!/bin/bash
# Copyright (c) 2018, Redmaner

DATE_CHECK=$(date +"%Y%m%d")
DATE_DAY=$(date +"%A")
DATE_FULL=$(date +"%m-%d-%Y-%H-%M-%S")
DATE_COMMIT=$(date +"%m %d %Y")

RES_GEN_PERIOD="7"

LISTS_DATE=$RES_DIR/.gen_lists
LISTS_DIR=$RES_DIR/language_value_lists
LISTS_DIR_NEW=$RES_DIR/language_value_lists_new

gen_list () {
if [ $LANG_VERSION -ge 8 ]; then
	case "$XML_TYPE" in

		arrays.xml)
		catch_values_arrays | while read value_entry; do
			cat $XML_TARGET | grep 'name="' | cut -d'"' -f2 | grep "$value_entry" | while read catched_entry; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					echo 'all '$APK' '$XML_TYPE' '$catched_entry'' >> $LISTS_DIR_NEW/MIUI"$LANG_VERSION"_"$LANG_NAME"_value_catcher.mxcr; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					echo ''$DIR' '$APK' '$XML_TYPE' '$catched_entry'' >> $LISTS_DIR_NEW/MIUI"$LANG_VERSION"_"$LANG_NAME"_value_catcher.mxcr; continue
				else
					continue
				fi
			done
		done;;

		strings.xml)
		catch_values_strings | while read value_entry; do
			cat $XML_TARGET | grep 'name="' | cut -d'"' -f2 | grep "$value_entry" | while read catched_entry; do
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="all" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					echo 'all '$APK' '$XML_TYPE' '$catched_entry'' >> $LISTS_DIR_NEW/MIUI"$LANG_VERSION"_"$LANG_NAME"_value_catcher.mxcr; continue
				else
					continue
				fi
				if [ $(cat $AUTO_IGNORELIST | grep 'folder="'$DIR'" application="'$APK'" file="'$XML_TYPE'" name="'$catched_entry'"/>' | wc -l) == 0 ]; then
					echo ''$DIR' '$APK' '$XML_TYPE' '$catched_entry'' >> $LISTS_DIR_NEW/MIUI"$LANG_VERSION"_"$LANG_NAME"_value_catcher.mxcr; continue
				else
					continue
				fi
			done
		done;;
	esac
fi
}

init_gen_lists () {
mkdir -p $LISTS_DIR $LISTS_DIR_NEW
cat $LANGS_ON | while read language; do
	init_lang $language
	if [ -d $LANG_DIR/$LANG_TARGET ]; then
		echo -e "${txtblu}Generating value list for $LANG_NAME MIUI$LANG_VERSION ($LANG_ISO)${txtrst}"
		rm -f $LISTS_DIR_NEW/MIUI"$LANG_VERSION"_"$LANG_NAME"_value_cather.mxcr
		find $LANG_DIR/$LANG_TARGET -iname "*.apk" | sort | while read apk_target; do 
			APK=$(basename $apk_target)
			DIR=$(basename $(dirname $apk_target))
			find $apk_target -iname "arrays.xml*" -o -iname "strings.xml*" -o -iname "plurals.xml*" | sort | while read XML_TARGET; do

				XML_TYPE=$(basename $XML_TARGET)

				if [ $(echo $XML_TYPE | grep ".part" | wc -l) -gt 0 ]; then
					case "$XML_TYPE" in
		   				strings.xml.part) XML_TYPE="strings.xml";;
						arrays.xml.part) XML_TYPE="arrays.xml";;
						plurals.xml.part) XML_TYPE="plurals.xml";;
					esac
				fi

				gen_list

			done
		done
	fi
done
}

day_correction () {
case $DATE_DAY in
	Monday)
	DATE_CHECK=$(($DATE_CHECK - 1));;

	Tuesday)
	DATE_CHECK=$(($DATE_CHECK - 2));;

	Wednesday)
	DATE_CHECK=$(($DATE_CHECK - 3));;

	Thursday)
	DATE_CHECK=$(($DATE_CHECK - 4));;

	Friday)
	DATE_CHECK=$(($DATE_CHECK - 5));;

	Saturday)
	DATE_CHECK=$(($DATE_CHECK - 6));;
esac
}

push_lists_to_git () {
echo -e "${txtblu}\nPusing new value catcher lists"
cd $RES_DIR
git add $LISTS_DIR
git add $LISTS_DIR_NEW
git commit -m "Update value catcher lists ($DATE_COMMIT)"
git push origin master
cd $MAIN_DIR
}

generate_value_catcher_lists_normal () {
if [ ! -e $LISTS_DATE ]; then
	init_gen_lists;
	day_correction
	echo $DATE_CHECK > $LISTS_DATE
	push_lists_to_git	
elif [ $(($DATE_CHECK - $(cat $LISTS_DATE))) -ge $RES_GEN_PERIOD ]; then
	rm -rf $LISTS_DIR
	mv $LISTS_DIR_NEW $LISTS_DIR
	init_gen_lists;
	day_correction
	echo $DATE_CHECK > $LISTS_DATE
	push_lists_to_git
fi
}

generate_value_catcher_lists_force () {
	rm -rf $LISTS_DIR
	mv $LISTS_DIR_NEW $LISTS_DIR
	init_gen_lists;
	day_correction
	echo $DATE_CHECK > $LISTS_DATE
	push_lists_to_git
}

