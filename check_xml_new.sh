#!/bin/bash
# Copyright (c) 2013 - 2015, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

#########################################################################################################
# CACHING
#########################################################################################################
build_cache () {
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
}

clear_cache () {
rm -rf $CACHE
}

assign_vars () {
XML_TARGET_STRIPPED=$FILE_CACHE/xml.target.stripped
APOSTROPHE_RESULT=$FILE_CACHE/xml.apostrophe.result
XML_LOG_TEMP=$FILE_CACHE/XML_LOG_TEMP
}

#########################################################################################################
# INITIAL LOGGING
#########################################################################################################
# Define logs
debug_mode () {
case "$DEBUG_MODE" in
 	double) 
	XML_LOG_FULL=$CACHE/XML_CHECK_FULL.html
	XML_LOG_FULL_NH=$CACHE/XML_CHECK_FULL-no_header
	update_log "$XML_LOG_FULL_NH"
	XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
      	XML_LOG_NH=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO-no_header;;

      	*) 
	XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
      	XML_LOG_NH=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO-no_header;;
esac
update_log "$XML_LOG_NH"
}

# Update log if log exsists (full/double debug mode) else create log
update_log () {
LOG_TARGET=$1
DATE=$(date +"%m-%d-%Y %H:%M:%S")
if [ -s $LOG_TARGET ]; then
     	LINE_NR=$(wc -l $LOG_TARGET | cut -d' ' -f1)
     	if [ "$(sed -n "$LINE_NR"p $LOG_TARGET)" == '<!-- Start of log --><script type="text/plain">' ]; then 
           	echo '</script></span><span class="green">No errors found in this repository!</span>' >> $LOG_TARGET
           	echo '</script><span class="header"><br><br>Checked ('$LANG_CHECK') <a href="'$LANG_URL'" title="'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO')" target="_blank">'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO') repository</a> on '$DATE'</span>' >> $LOG_TARGET
           	echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
     	else
           	echo '</script></span><span class="header"><br><br>Checked ('$LANG_CHECK') <a href="'$LANG_URL'" title="'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO')" target="_blank">'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO') repository</a> on '$DATE'</span>' >> $LOG_TARGET
           	echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
     	fi
else
	echo '</script></span><span class="header"><br><br>Checked ('$LANG_CHECK') <a href="'$LANG_URL'" title="'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO')" target="_blank">'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO') repository</a> on '$DATE'</span>' >> $LOG_TARGET
        echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
fi
}

create_log () {
LOG=$1
cat >> $LOG << EOF
<!DOCTYPE html>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<html>
<head>
<style>
body {
	margin: 0px 35px;
}
script {
  	display: block;
  	padding: auto;
}
.header {
  	font-weight: bold;
  	color: #000000;
}
.black {
  	color: #000000;
}
.green {
  	color: #006633;
}
.red {
  	color: #ff0000;
}
.blue {
  	color: #0000ff;
}
.orange {
  	color: #FF6633;
}
.brown {
  	color: #660000;
}
.pink {
	color: #FF14B1;
}
table {
        background-color: #ffffff;
        border-collapse: collapse;
        border-top: 0px solid #ffffff;
        border-bottom: 0px solid #ffffff;
        border-left: 0px solid #ffffff;
        border-right: 0px solid #ffffff;
        text-align: left;
        }

a, a:active, a:visited {
        color: #000000;
        text-decoration: none;
        }

a:hover {
        color: #ec6e00;
        text-decoration: underline;
        }

.error {
  	white-space: pre;
  	margin-top: -10px;
}
</style></head>
<body>
<a href="http://xiaomi.eu" title="xiaomi.eu Forums - Unofficial International MIUI / Xiaomi Phone Support"><img src="http://xiaomi.eu/community/styles/xiaomi/xenforo/xiaomi-europe-logo.png"></a>
<br><br>
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="auto" width="120px"><span class="green">Green text</span></td>
		<td height="auto" width="auto"><span class="black">No errors found</span><td>
	</tr>
	<tr>
		<td height="auto" width="120px"><span class="red">Red text</span></td>
		<td height="auto" width="auto"><span class="black">Parser error [Found in $COUNT_RED file(s)]</span></td><td>
	</td></tr>
	<tr>
		<td height="auto" width="120px"><span class="orange">Orange text</span></td>
		<td height="auto" width="auto"><span class="black">Double strings [Found in $COUNT_ORANGE file(s)]</span></td><td>
	</td></tr>
	<tr>
		<td height="auto" width="120px"><span class="brown">Brown text</span></td>
		<td height="auto" width="auto"><span class="black">Apostrophe syntax error  [Found in $COUNT_BROWN file(s)]</span></td><td>
	</td></tr>
	<tr>
		<td height="auto" width="120px"><span class="pink">Pink text</span></td>
		<td height="auto" width="auto"><span class="black">Untranslateable string, array or plural - Has to be removed from xml!  [Found in $COUNT_PINK file(s)]</span></td><td>
	</td></tr>
	<tr>
		<td height="auto" width="120px"><span class="blue">Blue text</span></td>
		<td height="auto" width="auto"><span class="black">'+' outside of tags  [Found in $COUNT_BLUE file(s)]</span></td><td>
	</td></tr>
</table>
EOF
}

check_log () {
LINE_NR=$(wc -l $XML_LOG | cut -d' ' -f1)
if [ "$(sed -n "$LINE_NR"p $XML_LOG)" == '<!-- Start of log --><script type="text/plain">' ]; then 
     	echo '</script><span class="green">No errors found in this repository!</span>' >> $XML_LOG
fi
case "$DEBUG_MODE" in
  	double) 
	echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked${txtrst}"
     	if [ "$LANG_URL" == "$LAST_URL" ]; then
		write_final_log "$XML_LOG_FULL_NH" "$XML_LOG_FULL"
        	LINE_NR=$(wc -l $XML_LOG_FULL | cut -d' ' -f1)
          	if [ "$(sed -n "$LINE_NR"p $XML_LOG_FULL)" == '<!-- Start of log --><script type="text/plain">' ]; then
               		echo '</script><span class="green">No errors found in this repository!</span>' >> $XML_LOG_FULL
          	fi
		rm -f $LOG_DIR/XML_*.html
		find $CACHE -iname "XML_*.html" | sort | while read complete_log; do
			cp $complete_log $LOG_DIR
		done
          	echo -e "${txtgrn}All languages checked, logs at $LOG_DIR${txtrst}"
    	fi;;

       *) 
	rm -f $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html 
	cp $XML_LOG $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
	echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked, log at logs/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html${txtrst}";;
esac
}

#########################################################################################################
# START XML CHECK
#########################################################################################################
init_xml_check () {
if [ -d $LANG_DIR/$LANG_TARGET ]; then
	echo -e "${txtblu}\nChecking $LANG_NAME MIUI$LANG_VERSION ($LANG_ISO)${txtrst}"
   	rm -f $APK_TARGETS
	debug_mode
	for apk_target in $(find $LANG_DIR/$LANG_TARGET -iname "*.apk" | sort); do
		APK=$(basename $apk_target)
		DIR=$(basename $(dirname $apk_target))
		for xml_target in $(find $apk_target -iname "arrays.xml*" -o -iname "strings.xml*" -o -iname "plurals.xml*"); do
			(xml_check "$xml_target")&
		done
		wait
	done
	write_log_finish
	write_final_log "$XML_LOG_NH" "$XML_LOG"
	check_log
fi
}

xml_check () {
XML_TARGET=$1

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

	FILE_CACHE=$CACHE/$LANG_TARGET/$DIR-$APK-$XML_TYPE
	mkdir -p $FILE_CACHE
	assign_vars
	echo "$XML_TARGET" > $FILE_CACHE/XML_TARGET

	case "$LANG_CHECK" in
		 basic) xml_check_parser; xml_check_doubles; xml_check_apostrophe; xml_check_plus; wait;;
		normal) xml_check_parser; xml_check_doubles; xml_check_apostrophe; xml_check_plus; xml_check_untranslateable; xml_check_untranslateable_auto; wait;;
	esac
fi
}

#########################################################################################################
# XML CHECK
#########################################################################################################
xml_check_parser () {
(
# Check for XML Parser errors
XML_LOG_PARSER=$FILE_CACHE/PARSER.log
xmllint --noout $XML_TARGET 2>> $XML_LOG_PARSER
write_log_error "red" "$XML_LOG_PARSER"
)&
}

xml_check_doubles () {
(
# Check for doubles
XML_LOG_DOUBLES=$FILE_CACHE/DOUBLES.log
if [ "$XML_TYPE" == "strings.xml" ]; then	
	cat $XML_TARGET | grep '<string name=' | cut -d'>' -f1 | cut -d'<' -f2 | sort | uniq --repeated | while read double; do
		grep -ne "$double" $XML_TARGET >> $XML_LOG_DOUBLES
	done
	write_log_error "orange" "$XML_LOG_DOUBLES"
fi
)&
}

xml_check_apostrophe () {
(
# Check for apostrophe errors
case "$XML_TYPE" in
	strings.xml)
	grep "<string" $XML_TARGET > $XML_TARGET_STRIPPED
	grep -v '>"' $XML_TARGET_STRIPPED > $APOSTROPHE_RESULT;;
	*)
	grep "<item>" $XML_TARGET > $XML_TARGET_STRIPPED
	grep -v '>"' $XML_TARGET_STRIPPED > $APOSTROPHE_RESULT;;
esac

if [ -e $APOSTROPHE_RESULT ]; then
	grep "'" $APOSTROPHE_RESULT > $XML_TARGET_STRIPPED
	grep -v "'\''" $XML_TARGET_STRIPPED > $APOSTROPHE_RESULT
	if [ -e $APOSTROPHE_RESULT ]; then
		XML_LOG_APOSTROPHE=$FILE_CACHE/APOSTROPHE.log
      	      	cat $APOSTROPHE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_LOG_APOSTROPHE
 	fi
fi
write_log_error "brown" "$XML_LOG_APOSTROPHE"
)&
}

xml_check_plus () {
(
# Check for '+' at the beginning of a line, outside <string>
XML_LOG_PLUS=$FILE_CACHE/PLUS.log
grep -ne "+ * <s" $XML_TARGET >> $XML_LOG_PLUS
write_log_error "blue" "$XML_LOG_PLUS"
);
}

xml_check_untranslateable () {
(
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
write_log_error "pink" "$XML_LOG_UNTRANSLATEABLE"
)&
}

xml_check_untranslateable_auto () {
(
# Check for untranslateable strings and arrays due automatically search for @
XML_LOG_UNTRANSLATEABLE_AUTO=$FILE_CACHE/UNTRANSLATEABLE_AUTO.log
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
		     done >> $XML_LOG_UNTRANSLATEABLE_AUTO;;
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
		     done >> $XML_LOG_UNTRANSLATEABLE_AUTO;;
esac
write_log_error "pink" "$XML_LOG_UNTRANSLATEABLE_AUTO"
)&
}

xml_check_array () {
# Count array items
if [ "$XML_TYPE" == "arrays.xml" ] && [ "$DIR" == "main" ]; then
	cat $XML_TARGET | grep 'name=' | while read array_count; do
		ARRAY_NAME=$(echo $array_count | cut -d'>' -f1 | cut -d'"' -f2)
		if [ $(cat $ARRAY_ITEM_LIST | grep ''$APK' '$ARRAY_NAME' ' | wc -l) -gt 0 ]; then
			ARRAY_TYPE=$(echo $array_count | cut -d' ' -f1 | cut -d'<' -f2)
			init_array_count $(cat $ARRAY_ITEM_LIST | grep ''$APK' '$ARRAY_NAME' ')
			TARGET_ARRAY_COUNT=$(arrays_count_items $ARRAY_NAME $ARRAY_TYPE $XML_TARGET)
			if [ "$TARGET_ARRAY_COUNT" != "$DIFF_ARRAY_COUNT" ]; then
				ARRAY=$(grep -ne '"'$ARRAY_NAME'"' $XML_TARGET)
				echo "$ARRAY - has $TARGET_ARRAY_COUNT items, should be $DIFF_ARRAY_COUNT items"
			fi
		fi
	done >> $XML_CACHE_LOG
fi				
write_log_error "teal"
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

write_log_finish () {
if [ "$DEBUG_MODE" == "double" ]; then
	for TEMP_LOG in $(find $CACHE/$LANG_TARGET -iname "XML_LOG_TEMP" | sort); do
		XML_TARGET=$(cat $(dirname $TEMP_LOG)/XML_TARGET)
		echo '</script><span class="black"><br>'$XML_TARGET'</span><span><script class="error" type="text/plain">' >> $XML_LOG_FULL_NH
		cat $TEMP_LOG >> $XML_LOG_FULL_NH
	done
fi
for TEMP_LOG in $(find $CACHE/$LANG_TARGET -iname "XML_LOG_TEMP" | sort); do
	XML_TARGET=$(cat $(dirname $TEMP_LOG)/XML_TARGET)
	echo '</script><span class="black"><br>'$XML_TARGET'</span><span><script class="error" type="text/plain">' >> $XML_LOG_NH
	cat $TEMP_LOG >> $XML_LOG_NH
done
}

write_final_log () {
LOG_NH=$1
LOG_NEW=$2

COUNT_RED=$(grep 'class="red"' $LOG_NH | wc -l)
COUNT_ORANGE=$(grep 'class="orange"' $LOG_NH | wc -l)
COUNT_BROWN=$(grep 'class="brown"' $LOG_NH | wc -l)
COUNT_PINK=$(grep 'class="pink"' $LOG_NH | wc -l)
COUNT_BLUE=$(grep 'class="blue"' $LOG_NH | wc -l)

create_log "$LOG_NEW"
cat $LOG_NH >> $LOG_NEW
rm -f $LOG_NH
}
