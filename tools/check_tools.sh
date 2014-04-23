#!/bin/bash
# Copyright (c) 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Variables
XML_TARGET_STRIPPED=$CACHE/xml.target.stripped
APOSTROPHE_RESULT=$CACHE/xml.apostrophe.result
XML_CACHE_LOG=$CACHE/XML_CACHE_LOG
XML_LOG_TEMP=$CACHE/XML_LOG_TEMP

#########################################################################################################
# INITIAL LOGGING
#########################################################################################################
# Define logs
debug_mode () {
case "$DEBUG_MODE" in
   full) XML_LOG=$CACHE/XML_LOG_FULL.html;;
 double) XML_LOG_FULL=$CACHE/XML_CHECK_FULL.html
       	 LOG_TARGET=$XML_LOG_FULL; update_log
       	 XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html;;
      *) XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html;;
esac
LOG_TARGET=$XML_LOG; update_log
}

# Update log if log exsists (full/double debug mode) else create log
update_log () {
DATE=$(date +"%m-%d-%Y %H:%M:%S")
if [ -e $LOG_TARGET ]; then
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
	create_log
fi
}

create_log () {
cat >> $LOG_TARGET << EOF
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
  	color: #CC6633;
}
.brown {
  	color: #660000;
}
.purple {
	color: #6633FF;
}
.teal { 
	color: #008080;
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
		<td height="auto" width="auto"><span class="black">Parser error</span><td>
	</tr>
	<tr>
		<td height="auto" width="120px"><span class="orange">Orange text</span></td>
		<td height="auto" width="auto"><span class="black">Double strings</span><td>
	</tr>
	<tr>
		<td height="auto" width="120px"><span class="brown">Brown text</span></td>
		<td height="auto" width="auto"><span class="black">Apostrophe syntax error</span><td>
	</tr>
	<tr>
		<td height="auto" width="120px"><span class="purple">Purple text</span></td>
		<td height="auto" width="auto"><span class="black">Untranslateable string, array or plural - Has to be removed from xml!</span><td>
	</tr>
	<tr>
		<td height="auto" width="120px"><span class="teal">Teal text</span></td>
		<td height="auto" width="auto"><span class="black">Incorrect amount of items in array</span><td>
	</tr>
	<tr>
		<td height="auto" width="120px"><span class="blue">Blue text</span></td>
		<td height="auto" width="auto"><span class="black">'+' outside of tags</span><td>
	</tr>
</table>
<span class="header"><br>Checked ($LANG_CHECK) <a href="$LANG_URL" title="$LANG_NAME MIUI$LANG_VERSION ($LANG_ISO)" target="_blank">$LANG_NAME MIUI$LANG_VERSION ($LANG_ISO) repository </a> on $DATE<br></span>
<!-- Start of log --><script type="text/plain">
EOF
}

check_log () {
LINE_NR=$(wc -l $XML_LOG | cut -d' ' -f1)
if [ "$(sed -n "$LINE_NR"p $XML_LOG)" == '<!-- Start of log --><script type="text/plain">' ]; then 
     	echo '</script><span class="green">No errors found in this repository!</span>' >> $XML_LOG
fi
case "$DEBUG_MODE" in
    full) if [ "$LANG_URL" == "$LAST_URL" ]; then
          	rm -f $LOG_DIR/XML_CHECK_FULL.html
          	cp $XML_LOG $LOG_DIR/XML_CHECK_FULL.html
          	echo -e "${txtgrn}All languages checked, log at logs/XML_CHECK_FULL.html${txtrst}"
     	  fi;;
  double) echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked${txtrst}"
     	  if [ "$LANG_URL" == "$LAST_URL" ]; then
          	LINE_NR=$(wc -l $XML_LOG_FULL | cut -d' ' -f1)
          	if [ "$(sed -n "$LINE_NR"p $XML_LOG_FULL)" == '<!-- Start of log --><script type="text/plain">' ]; then
               		echo '</script><span class="green">No errors found in this repository!</span>' >> $XML_LOG_FULL
          	fi
		find $CACHE -iname "XML_*.html" | sort | while read complete_log; do
			cp $complete_log $LOG_DIR
		done
          	echo -e "${txtgrn}All languages checked, logs at $LOG_DIR${txtrst}"
     	  fi;;
       *) rm -f $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
     	  cp $XML_LOG $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
     	  echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked, log at logs/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html${txtrst}";;
esac
}

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
		 basic) xml_check_basic; write_log_finish;;
		normal) xml_check_basic; xml_check_normal; write_log_finish;;
		  full) xml_check_basic; xml_check_normal; xml_check_full; write_log_finish;;
	esac
fi
}

#########################################################################################################
# XML CHECK
#########################################################################################################
xml_check_basic () {
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

xml_check_normal () {
# Check for untranslateable strings, arrays, plurals using untranslateable list
if [ $(cat $UNTRANSLATEABLE_LIST | grep ''$APK' '$XML_TYPE' ' | wc -l) -gt 0 ]; then
	cat $UNTRANSLATEABLE_LIST | grep 'all '$APK' '$XML_TYPE' ' | while read all_line; do
		init_ignorelist $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
		grep -ne '"'$ITEM_NAME'"' $XML_TARGET
	done >> $XML_CACHE_LOG
	cat $UNTRANSLATEABLE_LIST | grep ''$DIR' '$APK' '$XML_TYPE' ' | while read all_line; do
		init_ignorelist $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
		grep -ne '"'$ITEM_NAME'"' $XML_TARGET
	done >> $XML_CACHE_LOG
	if [ "$DIR" != "main" ]; then
		cat $UNTRANSLATEABLE_LIST | grep 'devices '$APK' '$XML_TYPE' ' | while read all_line; do
			init_ignorelist $(cat $UNTRANSLATEABLE_LIST | grep "$all_line")
			grep -ne '"'$ITEM_NAME'"' $XML_TARGET
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
}

xml_check_full () {
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
