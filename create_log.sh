#!/bin/bash
# Copyright (c) 2013 - 2015, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

make_logs () {
for cached_check in $(find $CACHE -iname "*.cached" | sort); do
	init_lang $(cat $LANGS_ON | grep ''$(cat $cached_check/lang_name)' '$(cat $cached_check/lang_version)'');
	if [ "$DEBUG_MODE" == "double" ]; then
		XML_LOG_FULL=$CACHE/XML_CHECK_FULL.html
		XML_LOG_FULL_NH=$CACHE/XML_CHECK_FULL-no_header 
	fi
	XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
      	XML_LOG_NH=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO-no_header

	echo '</script></span><span class="header"><br><br>Checked ('$LANG_CHECK') <a href="'$LANG_URL'" title="'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO')" target="_blank">'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO') repository</a> on '$(cat $cached_check/datestamp)'</span>' >> $XML_LOG_NH
        echo '<!-- Start of log --><script type="text/plain">' >> $XML_LOG_NH

	for TEMP_LOG in $(find $cached_check -iname "XML_LOG_TEMP" | sort); do
		XML_TARGET=$(cat $(dirname $TEMP_LOG)/XML_TARGET)
		echo '</script><span class="black"><br>'$XML_TARGET'</span><span><script class="error" type="text/plain">' >> $XML_LOG_NH
		cat $TEMP_LOG >> $XML_LOG_NH
	done

	LINE_NR=$(wc -l $XML_LOG_NH | cut -d' ' -f1)
     	if [ "$(sed -n "$LINE_NR"p $XML_LOG_NH)" == '<!-- Start of log --><script type="text/plain">' ]; then 
           	echo '</script></span><span class="green">No errors found in this repository!</span>' >> $XML_LOG_NH
	fi

	if [ "$DEBUG_MODE" == "double" ]; then
		cat $XML_LOG_NH >> $XML_LOG_FULL_NH 
		write_final_log "$XML_LOG_NH" "$XML_LOG"
		if [ "$LANG_URL" == "$LAST_URL" ]; then
			write_final_log "$XML_LOG_FULL_NH" "$XML_LOG_FULL"
			rm -f $LOG_DIR/XML_*.html
			for html in $(find $CACHE -iname "XML_*.html"); do
				cp $html $LOG_DIR
			done
			echo -e "${txtgrn}All languages checked, logs at $LOG_DIR${txtrst}"
		fi
	else
		write_final_log "$XML_LOG_NH" "$XML_LOG"
		cp $XML_LOG $LOG_DIR
		echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked, log at logs/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html${txtrst}"
	fi
	
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

