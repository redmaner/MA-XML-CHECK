#!/bin/bash
# Copyright (c) 2013 - 2015, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

make_logs () {
if [ $INDEX_LOGS == "true" ]; then
	create_index
fi

LANGS_IN_CACHE=$(find $CACHE -iname "*.cached" | wc -l);
LANG_COUNT=0
find $CACHE -iname "*.cached" | sort | while read cached_check; do
	LANG_COUNT=$(expr $LANG_COUNT + 1)
	init_lang $(cat $LANGS_ALL | grep ''$(cat $cached_check/lang_version)' '$(cat $cached_check/lang_name)'');
	if [ "$DEBUG_MODE" == "double" ]; then
		XML_LOG_FULL=$CACHE/XML_CHECK_FULL.html
		XML_LOG_FULL_NH=$CACHE/XML_CHECK_FULL-no_header 
	fi
	XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
    	XML_LOG_NH=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO-no_header

	if [ -f $cached_check/prev_log ]; then
		XML_LOG_NH=$cached_check/prev_log
	else
		cp $cached_check/datestamp $DATA_DIR/$LANG_TARGET/datestamp
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
	fi

	if [ "$DEBUG_MODE" == "double" ]; then
		cat $XML_LOG_NH >> $XML_LOG_FULL_NH 
		write_final_log "$XML_LOG_NH" "$XML_LOG" true
		if [ "$LANGS_IN_CACHE" == "$LANG_COUNT" ]; then
			write_final_log "$XML_LOG_FULL_NH" "$XML_LOG_FULL" false
			rm -f $LOG_DIR/XML_*.html
			for html in $(find $CACHE -iname "XML_*.html"); do
				cp $html $LOG_DIR
			done
			echo -e "${txtgrn}All languages checked, logs at $LOG_DIR${txtrst}"
		fi
	else
		write_final_log "$XML_LOG_NH" "$XML_LOG" true
		cp $XML_LOG $LOG_DIR
		echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked, log at logs/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html${txtrst}"
	fi

	if [ $INDEX_LOGS == "true" ]; then
		INDEX_LOG_TARGET=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
		if [ $(grep 'No errors found in this repository!' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
			add_to_index "No errors found" "" "" "" "" "" "" ""
		else
			INDEX_RED=""
			INDEX_ORANGE=""
			INDEX_BROWN=""
			INDEX_PINK=""
			INDEX_CYAN=""
			INDEX_BLUE=""
			INDEX_GREY=""
			INDEX_GOLD=""
			if [ $(grep 'class="red"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_RED="Has parser error(s) | "
			fi
			if [ $(grep 'class="orange"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_ORANGE="Has doubles | "
			fi
			if [ $(grep 'class="brown"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_BROWN="Has apostrophe error(s) | "
			fi
			if [ $(grep 'class="pink"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_PINK="Has untranslateable(s) | "
			fi
			if [ $(grep 'class="cyan"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_CYAN="Has wrong value folder(s) | "
			fi
			if [ $(grep 'class="blue"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_BLUE="Has + error(s) | "
			fi
			if [ $(grep 'class="grey"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_GREY="Has variable error(s)"
			fi
			if [ $(grep 'class="gold"><script' $INDEX_LOG_TARGET | wc -l) -gt 0 ]; then
				INDEX_GOLD="Has formatted=false"
			fi
			add_to_index "" "$INDEX_RED" "$INDEX_ORANGE" "$INDEX_BROWN" "$INDEX_PINK" "$INDEX_CYAN" "$INDEX_BLUE" "$INDEX_GREY" "$INDEX_GOLD"
		fi
	fi

done

if [ $INDEX_LOGS == "true" ]; then
	echo '</body></html>' >> $LOG_DIR/index.html.bak
	mv $LOG_DIR/index.html.bak $LOG_DIR/index.html
fi
}

write_final_log () {
LOG_NH=$1
LOG_NEW=$2
COPY_LOG=$3

COUNT_RED=$(grep 'class="red"' $LOG_NH | wc -l)
COUNT_ORANGE=$(grep 'class="orange"' $LOG_NH | wc -l)
COUNT_BROWN=$(grep 'class="brown"' $LOG_NH | wc -l)
COUNT_PINK=$(grep 'class="pink"' $LOG_NH | wc -l)
COUNT_CYAN=$(grep 'class="cyan"' $LOG_NH | wc -l)
COUNT_BLUE=$(grep 'class="blue"' $LOG_NH | wc -l)
COUNT_GREY=$(grep 'class="grey"' $LOG_NH | wc -l)
COUNT_GOLD=$(grep 'class="gold"' $LOG_NH | wc -l)

create_log "$LOG_NEW"
cat $LOG_NH >> $LOG_NEW
cat >> $LOG_NEW << EOF
</script>
</body>
</html>
EOF

if [ $COPY_LOG == true ]; then
	cp $LOG_NH $DATA_DIR/$LANG_TARGET/prev_log
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
.cyan {
	color: #0099FF;
}
.grey {
	color: #464646;
}
.gold {
	color: #B88A00
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
<a href="http://translators.xiaomi.eu" title="xiaomi.eu Translators home"><img width="20%" height="20%" src="https://s16.postimg.org/9heai94lx/xiaomi_europe_logo77.png"></a>
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
		<td height="auto" width="120px"><span class="cyan">Cyan text</span></td>
		<td height="auto" width="auto"><span class="black">Wrong values folder  [Found in $COUNT_CYAN file(s)]</span></td><td>
	</td></tr>
	<tr>
		<td height="auto" width="120px"><span class="blue">Blue text</span></td>
		<td height="auto" width="auto"><span class="black">'+' outside of tags  [Found in $COUNT_BLUE file(s)]</span></td><td>
	</td></tr>
	<tr>
		<td height="auto" width="120px"><span class="grey">Grey text</span></td>
		<td height="auto" width="auto"><span class="black">Invalid variable formatting  [Found in $COUNT_GREY file(s)]</span></td><td>
	</td></tr>
	<tr>
		<td height="auto" width="120px"><span class="gold">Gold text</span></td>
		<td height="auto" width="auto"><span class="black">Requires formatted=false  [Found in $COUNT_GOLD file(s)]</span></td><td>
	</td></tr>
</table>
EOF
}

create_index () {
cat > $LOG_DIR/index.html.bak << EOF
<!DOCTYPE html>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<html>
<head>
<style>
body {
	margin: 0px 35px;
}
.header {
  	font-weight: bold;
	font-size: 150%;
  	color: #ec6e00;
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
.cyan {
	color: #0099FF;
}
.grey {
	color: #464646;
}
.gold {
	color: #B88A00
}
a, a:active, a:visited {
        color: #000000;
        text-decoration: none;
        }

a:hover {
        color: #ec6e00;
        text-decoration: underline;
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
</style></head>
<body>
<a href="http://xiaomi.eu" title="xiaomi.eu Forums - Unofficial International MIUI / Xiaomi Support"><img  width="20%" height="20%" src="https://s16.postimg.org/9heai94lx/xiaomi_europe_logo77.png"></a>
<br><br>
<span class="header">LOGS</span><br><br>
<a href="$INDEX_LOG_HREF/XML_CHECK_FULL.html" title="Universal log"><b>Universal log</b></a><br><br>
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="auto" width="7%"><span class="black"><b>Version</b></span></td>
		<td height="auto" width="25%"><span class="black"><b>Language repository</b></span></td>
		<td height="auto" width="25%"><span class="black"><b>Last check</b></span></td>
		<td height="auto" width="auto"><span class=black"><b>Status</b></span></td>
	</tr>
EOF
}

add_to_index() {
INDEX_TIME=$(cat $CACHE/$LANG_TARGET.cached/datestamp)
cat >> $LOG_DIR/index.html.bak << EOF
	<tr>
		<td height="auto" width="7%"><span class="black">MIUI$LANG_VERSION</span></td>
		<td height="auto" width="25%"><span class="black"><a href="$INDEX_LOG_HREF/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html" title="$LANG_NAME MIUI$LANG_VERSION">$LANG_NAME ($LANG_ISO)</a></span></td>
		<td height="auto" width="25%"><span class="black">$INDEX_TIME</span></td>
		<td height="auto" width="auto"><span class="green">$1</span><span class="red">$2</span><span class="orange">$3</span><span class="brown">$4</span><span class="pink">$5</span><span class="cyan">$6</span><span class="blue">$7</span><span class="grey">$8</span><span class="gold">$9</span></td>
	</tr>
EOF
}
