#!/bin/bash
# Copyright (c) 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

#########################################################################################################
# INITIAL LOGGING
#########################################################################################################
# Define logs
debug_mode () {
case "$DEBUG_MODE" in
   full) XML_LOG=$CACHE/XML_LOG_FULL;;
 double) XML_LOG_FULL=$CACHE/XML_CHECK_FULL
       	 LOG_TARGET=$XML_LOG_FULL; update_log
       	 XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO;;
      *) XML_LOG=$CACHE/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO;;
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
           	echo '</script><span class="header"><br><br>Checked <a href="'$LANG_URL'" title="'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO')" target="_blank">'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO') repository</a> on '$DATE'</span>' >> $LOG_TARGET
           	echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
     	else
           	echo '</script></span><span class="header"><br><br>Checked <a href="'$LANG_URL'" title="'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO')" target="_blank">'$LANG_NAME' MIUI'$LANG_VERSION' ('$LANG_ISO') repository</a> on '$DATE'</span>' >> $LOG_TARGET
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
<span class="header"><br>Checked <a href="$LANG_URL" title="$LANG_NAME MIUI$LANG_VERSION ($LANG_ISO)" target="_blank">$LANG_NAME MIUI$LANG_VERSION ($LANG_ISO) repository</a> on $DATE<br></span>
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
  double) rm -f $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
     	  cp $XML_LOG $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
    	  echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked, log at logs/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html${txtrst}"
     	  if [ "$LANG_URL" == "$LAST_URL" ]; then
          	LINE_NR=$(wc -l $XML_LOG_FULL | cut -d' ' -f1)
          	if [ "$(sed -n "$LINE_NR"p $XML_LOG_FULL)" == '<!-- Start of log --><script type="text/plain">' ]; then
               		echo '</script><span class="green">No errors found in this repository!</span>' >> $XML_LOG_FULL
          	fi
          	cp $XML_LOG_FULL $LOG_DIR/XML_CHECK_FULL.html
          	echo -e "${txtgrn}All languages checked, log at logs/XML_CHECK_FULL.html${txtrst}"
     	  fi;;
       *) rm -f $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
     	  cp $XML_LOG $LOG_DIR/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html
     	  echo -e "${txtgrn}$LANG_NAME ($LANG_ISO) checked, log at logs/XML_MIUI$LANG_VERSION-$LANG_NAME-$LANG_ISO.html${txtrst}";;
esac
chmod 777 $LOG_DIR/XML_*.html
}
