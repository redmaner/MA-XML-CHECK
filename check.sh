#!/bin/bash
case `uname -s` in
    Darwin) 
           txtrst='\033[0m' # Color off
           txtred='\033[0;31m' # Red
           txtgrn='\033[0;32m' # Green
           txtblu='\033[0;34m' # Blue
           ;;
    *)
           txtrst='\e[0m' # Color off
           txtred='\e[1;31m' # Red
           txtgrn='\e[1;32m' # Green
           txtblu='\e[1;36m' # Blue
           ;;
esac

# Determine server or a local machine
if [ -d /home/translators.xiaomi.eu ]; then
     	MAIN_DIR=/home/translators.xiaomi.eu/scripts
     	LOG_DIR=/home/translators.xiaomi.eu/public_html
else
     	MAIN_DIR=$PWD
     	LOG_DIR=$PWD/logs
fi


#########################################################################################################
# VARIABLES / CACHE
#########################################################################################################
LANG_XML=$MAIN_DIR/languages/languages.xml

build_cache () {
if [ -d $MAIN_DIR/.cache ]; then
	if [ -e $MAIN_DIR/.cache/PLACEHOLDER ]; then
		if [ -e $MAIN_DIR/.cache1/PLACEHOLDER ]; then
			echo -e "${txtred}\nTwo processes are currently running, please wait till a proces is complete${txtrst}"; exit
		else
			mkdir -p $MAIN_DIR/.cache1
			CACHE=$MAIN_DIR/.cache1
			touch $CACHE/PLACEHOLDER
		fi
	else
		rm -rf $MAIN_DIR/.cache
		mkdir -p $MAIN_DIR/.cache
		CACHE=$MAIN_DIR/.cache
		touch $CACHE/PLACEHOLDER
	fi
else
	mkdir -p $MAIN_DIR/.cache
	CACHE=$MAIN_DIR/.cache
	touch $CACHE/PLACEHOLDER
fi
XML_TARGETS_ARRAYS=$CACHE/xml.targets.arrays
XML_TARGETS_STRINGS=$CACHE/xml.targets.strings
XML_TARGETS_PLURALS=$CACHE/xml.targets.plurals
XML_TARGET_STRIPPED=$CACHE/xml.target.stripped
DOUBLE_RESULT=$CACHE/xml.double.result
APOSTROPHE_RESULT=$CACHE/xml.apostrophe.result
XML_CACHE_LOG=$CACHE/XML_CACHE_LOG
XML_LOG_TEMP=$CACHE/XML_LOG_TEMP
}

clear_cache () {
rm -rf $CACHE
}

clean_cache () {
rm -f $XML_TARGETS_STRIPPED
rm -f $DOUBLE_RESULT
rm -f $OPOSTROPHE_RESULT
rm -f $XML_CACHE_LOG
}

#########################################################################################################
# INITIAL LOGGING
#########################################################################################################
debug_mode () {
if [ "$DEBUG_MODE" = "full" ]; then
     	XML_LOG=$CACHE/XML_CHECK_FULL
elif [ "$DEBUG_MODE" = "double" ]; then
       	XML_LOG_FULL=$CACHE/XML_CHECK_FULL
       	LOG_TARGET=$XML_LOG_FULL; update_log
       	XML_LOG=$CACHE/XML_$LANG_NAME-$LANG_TARGET
else
     	XML_LOG=$CACHE/XML_$LANG_NAME-$LANG_TARGET
fi
LOG_TARGET=$XML_LOG; update_log
}

update_log () {
DATE=$(date +"%m-%d-%Y %H:%M:%S")
if [ -e $LOG_TARGET ]; then
     	LINE_NR=$(wc -l $LOG_TARGET | cut -d' ' -f1)
     	if [ "$(sed -n "$LINE_NR"p $LOG_TARGET)" = '<!-- Start of log --><script type="text/plain">' ]; then 
           	echo '</script></span><span class="green">No errors found in this repository!</span>' >> $LOG_TARGET
           	echo '</script><span class="header"><br><br>Checked <a href="'$LANG_URL'" title="'$LANG_NAME' ('$LANG_TARGET')" target="_blank">'$LANG_NAME' ('$LANG_TARGET') repository</a> on '$DATE'</span>' >> $LOG_TARGET
           	echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
     	else
           	echo '</script></span><span class="header"><br><br>Checked <a href="'$LANG_URL'" title="'$LANG_NAME' ('$LANG_TARGET')" target="_blank">'$LANG_NAME' ('$LANG_TARGET') repository</a> on '$DATE'</span>' >> $LOG_TARGET
           	echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
     	fi
else
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
table {
        background-color: #ffffff;
        border-collapse: collapse;
        border-top: 0px solid #000000;
        border-bottom: 1px solid #000000;
        border-left: 0px solid #000000;
        border-right: 0px solid #000000;
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
<td height="auto" width="120px"><span class="green">Green text</span></td>
<td height="auto" width="220px"><span class="black">No errors found</span><td>
</table>
<table border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><span class="red">Red text</span></td>
<td height="auto" width="220px"><span class="black">Parser error</span><td>
</table>
<table border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><span class="orange">Orange text</span></td>
<td height="auto" width="220px"><span class="black">Double strings</span><td>
</table>
<table  border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><span class="brown">Brown text</span></td>
<td height="auto" width="220px"><span class="black">Apostrophe syntax error</span><td>
</table>
<table border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><span class="blue">Blue text</span></td>
<td height="auto" width="220px"><span class="black">'+' outside of tags</span><td>
</table>
<span class="header"><br>Checked <a href="$LANG_URL" title="$LANG_NAME ($LANG_TARGET)" target="_blank">$LANG_NAME ($LANG_TARGET) repository</a> on $DATE<br></span>
<!-- Start of log --><script type="text/plain">
EOF
fi
}

check_log () {
LINE_NR=$(wc -l $XML_LOG | cut -d' ' -f1)
if [ "$(sed -n "$LINE_NR"p $XML_LOG)" = '<!-- Start of log --><script type="text/plain">' ]; then 
     	echo '</script><span class="green">No errors found in this repository!</span>' >> $XML_LOG
fi
if [ $DEBUG_MODE = "full" ]; then
     	if [ "$LANG_TARGET" = "$LAST_TARGET" ]; then
          	rm -f $LOG_DIR/XML_CHECK_FULL.html
          	cp $XML_LOG $LOG_DIR/XML_CHECK_FULL.html
          	echo -e "${txtgrn}All languages checked, log at logs/XML_CHECK_FULL.html${txtrst}"
     	fi
elif [ $DEBUG_MODE = "double" ]; then
	rm -f $LOG_DIR/XML_$LANG_NAME-$LANG_TARGET.html
     	cp $XML_LOG $LOG_DIR/XML_$LANG_NAME-$LANG_TARGET.html
    	echo -e "${txtgrn}$LANG_NAME ($LANG_TARGET) checked, log at logs/XML_$LANG_NAME-$LANG_TARGET.html${txtrst}"
     	if [ "$LANG_TARGET" = "$LAST_TARGET" ]; then
          	LINE_NR=$(wc -l $XML_LOG_FULL | cut -d' ' -f1)
          	if [ "$(sed -n "$LINE_NR"p $XML_LOG_FULL)" = '<!-- Start of log --><script type="text/plain">' ]; then
               		echo '</script><span class="green">No errors found in this repository!</span>' >> $XML_LOG_FULL
          	fi
          	cp $XML_LOG_FULL $LOG_DIR/XML_CHECK_FULL.html
          	echo -e "${txtgrn}All languages checked, log at logs/XML_CHECK_FULL.html${txtrst}"
     	fi
else
     	rm -f $LOG_DIR/XML_$LANG_NAME-$LANG_TARGET.html
     	cp $XML_LOG $LOG_DIR/XML_$LANG_NAME-$LANG_TARGET.html
     	echo -e "${txtgrn}$LANG_NAME ($LANG_TARGET) checked, log at logs/XML_$LANG_NAME-$LANG_TARGET.html${txtrst}"
fi
chmod 777 $LOG_DIR/XML_*.html
}

#########################################################################################################
# XML CHECK
#########################################################################################################
init_xml_check () {
if [ -d $MAIN_DIR/languages/$LANG_TARGET ]; then
   	echo -e "${txtblu}\nChecking $LANG_NAME ($LANG_TARGET)${txtrst}"
   	rm -f $XML_TARGETS_ARRAYS $XML_TARGETS_STRINGS $XML_TARGETS_PLURALS
   	find $MAIN_DIR/languages/$LANG_TARGET -iname "arrays.xml" >> $XML_TARGETS_ARRAYS
   	find $MAIN_DIR/languages/$LANG_TARGET -iname "arrays.xml.part" >> $XML_TARGETS_ARRAYS 
   	find $MAIN_DIR/languages/$LANG_TARGET -iname "strings.xml" >> $XML_TARGETS_STRINGS
   	find $MAIN_DIR/languages/$LANG_TARGET -iname "strings.xml.part" >> $XML_TARGETS_STRINGS 
   	find $MAIN_DIR/languages/$LANG_TARGET -iname "plurals.xml" >> $XML_TARGETS_PLURALS
   	find $MAIN_DIR/languages/$LANG_TARGET -iname "plurals.xml.part" >> $XML_TARGETS_PLURALS 
   	sort $XML_TARGETS_ARRAYS > $XML_TARGETS_ARRAYS.new; mv $XML_TARGETS_ARRAYS.new $XML_TARGETS_ARRAYS
   	sort $XML_TARGETS_STRINGS > $XML_TARGETS_STRINGS.new; mv $XML_TARGETS_STRINGS.new $XML_TARGETS_STRINGS
   	sort $XML_TARGETS_PLURALS > $XML_TARGETS_PLURALS.new; mv $XML_TARGETS_PLURALS.new $XML_TARGETS_PLURALS
   	debug_mode
   	start_xml_check
	check_log
fi
}

start_xml_check () {
cat $XML_TARGETS_ARRAYS | while read all_line; do
    	xml_check "$all_line" arrays
done; clean_cache
cat $XML_TARGETS_STRINGS | while read all_line; do
    	xml_check "$all_line" strings
done; clean_cache
cat $XML_TARGETS_PLURALS | while read all_line; do
    	xml_check "$all_line" plurals
done; clean_cache
}

xml_check () {
XML=$1
XML_TARGET=$(echo $XML)
XML_TYPE=$2

rm -f $XML_CACHE_LOG
rm -f $XML_LOG_TEMP
if [ -e "$XML_TARGET" ]; then
     	# Check for XML Parser errors
     	xmllint --noout $XML_TARGET 2>> $XML_CACHE_LOG
	write_log

     	# Check for doubles in strings.xml
     	if [ "$XML_TYPE" = "strings" ]; then
          	cat $XML_TARGET | while read all_line; do grep "<string" | cut -d'>' -f1; done > $XML_TARGET_STRIPPED
          	sort $XML_TARGET_STRIPPED | uniq --repeated > $DOUBLE_RESULT
          	cat $DOUBLE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_CACHE_LOG
		write_log_error "orange"
     	fi

     	# Check for apostrophe errors in strings.xml
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
	write_log_finish
fi
}

write_log_error () {
if [ -s $XML_CACHE_LOG ]; then
	echo '</script><span class="'$1'"><script class="error" type="text/plain">' >> $XML_LOG_TEMP
	cat $XML_CACHE_LOG >> $XML_LOG_TEMP
fi
rm -f $XML_CACHE_LOG
}

write_log_finish () {
if [ -s $XML_LOG_TEMP ]; then
	if [ "$DEBUG_MODE" = "double" ]; then
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

#########################################################################################################
# PULL LANGUAGES
#########################################################################################################
pull_lang () {
if [ "$PULL_FLAG" != "" ]; then
	if [ $PULL_FLAG = "force" ]; then
		rm -rf $MAIN_DIR/languages/$PULL_ISO; sleep 1; sync
	fi
fi
echo -e "${txtblu}\nSyncing $PULL_NAME${txtrst}"
if [ -e $MAIN_DIR/languages/$PULL_ISO ]; then
     	cd $MAIN_DIR/languages/$PULL_ISO; git pull origin $PULL_BRANCH; cd ../../..
else
     	git clone $PULL_GIT  -b $PULL_BRANCH $MAIN_DIR/languages/$PULL_ISO
fi
}

pull_languages_xml () {
wget -q https://raw.github.com/Redmaner/MA-XML-LANGUAGES/master/languages.xml -O $LANG_XML
}

#########################################################################################################
# ARGUMENTS
#########################################################################################################
show_argument_help () { 
echo 
echo "MIUIAndroid.com language repo XML check $VERSION"
echo 
echo "Usage: check.sh [option]"
echo 
echo " [option]:"
echo " 		--help					This help"
echo "		--check [all|language] [full|double]	Check specified language"
echo "							If all is specified, then all languages will be checked"
echo "							If a specific language is specified, that language will be checked"
echo "							If third argument is not defined, all languages will be logged in seperate files"
echo "							If third argument is 'full', all languages will be logged in one file"
echo "							If third argument is 'double', all languages will be logged in one file and in seperate files"
echo "		--pull [all|language] [force]		Pull specified language"
echo "							If all is specified, then all languages will be pulled"
echo "							If a specific language is specified, that language will be pulled"
echo "							If force is specified, language(s) will be removed and resynced"
echo "		--remove [logs|all|language]		Removes logs and or language(s)"
echo 
exit 
}

if [ $# -gt 0 ]; then
     	if [ $1 == "--help" ]; then
          	show_argument_help
     	elif [ $1 == "--check" ]; then
		build_cache
		pull_languages_xml
            	DEBUG_MODE=lang
            	case "$2" in
		  	all) if [ "$3" = "full" ]; then
                                 DEBUG_MODE=full
                             elif [ "$3" = "double" ]; then
                               	 DEBUG_MODE=double
                             fi; 
			     LINE_NR=$(cat $LANG_XML | grep '<language enabled="yes"' | wc -l)
			     LAST_TARGET=$(cat $LANG_XML | grep '<language enabled="yes"' | sed -n "$LINE_NR"p | awk '{print $4}' | cut -d'"' -f2)
			     cat $LANG_XML | grep '<language enabled="yes"' | while read all_line; do
					LANG_TARGET=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
				      	LANG_NAME=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
					LANG_URL=$(echo $all_line | awk '{print $5}' | cut -d'"' -f2)
                        		init_xml_check
   			     done;;
			  *) if [ "`cat $LANG_XML | grep 'name="'$2'"' | wc -l`" -gt 0 ]; then
					LANG_TARGET=$(cat $LANG_XML | grep 'name="'$2'"' | awk '{print $4}' | cut -d'"' -f2) 
				      	LANG_NAME=$(cat $LANG_XML | grep 'name="'$2'"' | awk '{print $3}' | cut -d'"' -f2)
					LANG_URL=$(cat $LANG_XML | grep 'name="'$2'"'| awk '{print $5}' | cut -d'"' -f2)
                                 	init_xml_check
                             else
					echo "Language not supported or language not specified"; exit
			     fi;;
           	esac
		clear_cache
     	elif [ $1 == "--pull" ]; then
		pull_languages_xml
            	case "$2" in
			all) cat $LANG_XML | grep '<language enabled="yes"' | while read all_line; do
					if [ "$3" != "" ]; then
   						if [ $3 = "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					PULL_NAME=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
					PULL_ISO=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2) 
					PULL_GIT=$(echo $all_line | awk '{print $6}' | cut -d'"' -f2)
					PULL_BRANCH=$(echo $all_line | awk '{print $7}' | cut -d'"' -f2)
                        		pull_lang
   			     done;;
			  *) if [ "`cat $LANG_XML | grep 'name="'$2'"' | wc -l`" -gt 0 ]; then
					if [ "$3" != "" ]; then
   						if [ $3 = "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					PULL_NAME=$(cat $LANG_XML | grep 'name="'$2'"' | awk '{print $3}' | cut -d'"' -f2)
					PULL_ISO=$(cat $LANG_XML | grep 'name="'$2'"' | awk '{print $4}' | cut -d'"' -f2) 
					PULL_GIT=$(cat $LANG_XML | grep 'name="'$2'"' | awk '{print $6}' | cut -d'"' -f2)
					PULL_BRANCH=$(cat $LANG_XML | grep 'name="'$2'"' | awk '{print $7}' | cut -d'"' -f2)
                        		pull_lang 
                             else
					echo "Language not supported or language not specified"; exit
			     fi;;
           	esac
     	elif [ $1 == "--remove" ]; then
		pull_languages_xml
            	if [ "$2" != " " ]; then
                 	case "$2" in
                             logs) rm -f $LOG_DIR/XML_*.html;;
                              all) cat $LANG_XML | grep '<language enabled=' | while read all_line; do
					RM_ISO=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
                        		rm -rf $MAIN_DIR/languages/$RM_ISO 
   			           done;;
				*) if [ "`cat $LANG_XML | grep 'name="'$2'"' | wc -l`" -gt 0 ]; then
						RM_ISO=$(cat $LANG_XML | grep 'name="'$2'"' | awk '{print $4}' | cut -d'"' -f2) 
                        			rm -rf $MAIN_DIR/languages/$RM_ISO 
                             	   else
						echo "Language not supported or language not specified"; exit
			           fi;;
                 	esac 
            	fi
     	else
            	show_argument_help; exit
     	fi
else
     	show_argument_help; exit
fi
