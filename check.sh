#!/bin/bash
# Copyright (c) 2013 - 2014, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

# Define bash colors for Mac OSX / Linux
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
	RES_DIR=/home/translators.xiaomi.eu/scripts/resources
	SERVER=yes
else
     	MAIN_DIR=$PWD
     	LOG_DIR=$PWD/logs
	RES_DIR=$PWD/resources
	SERVER=no
fi

if [ ! -e $MAIN_DIR/languages ]; then
	mkdir -p $MAIN_DIR/languages
fi

if [ ! -e $LOGDIR ]; then
	mkdir -p $LOGDIR
fi


#########################################################################################################
# VARIABLES / CACHE
#########################################################################################################
VERSION=4.0
RESOURCES_GIT="git@github.com:Redmaner/MA-XML-CHECK-RESOURCES.git"
RESOURCES_BRANCH="4.0-dev"
RESOURCES_SYNC_COUNT=$RES_DIR/sync_count
LANG_XML=$RES_DIR/languages.xml
ARRAY_TOOLS=$RES_DIR/array_tools.sh

build_cache () {
DATE=$(date +"%m-%d-%Y-%H-%M-%S")
CACHE="$MAIN_DIR/.cache-$DATE"
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
XML_TARGET_STRIPPED=$CACHE/xml.target.stripped
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
	DIR=$(basename $(dirname $(echo $XML_TARGET | cut -d'.' -f1)))

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
	cat $UNTRANSLATEABLE_LIST | grep 'application="'$APK'" file="'$XML_TYPE'"' | while read all_line; do
		UNTRANSLATEABLE_STRING=$(echo $all_line | awk '{print $4}' | cut -d'/' -f1)
		grep -ne ''$UNTRANSLATEABLE_STRING'' $XML_TARGET
	done >> $XML_CACHE_LOG
fi

# Check for untranslateable strings and arrays due automatically search for @
case "$XML_TYPE" in 
	strings.xml) grep -ne '@android\|@string\|@color\|@drawable' $XML_TARGET >> $XML_CACHE_LOG;;
	 arrays.xml) cat $XML_TARGET | grep 'name="' | while read arrays; do
				ARRAY_TYPE=$(echo $arrays | cut -d' ' -f1 | cut -d'<' -f2)
				ARRAY_NAME=$(echo $arrays | cut -d'>' -f1 | cut -d'"' -f2)
				if [ $(arrays_parse $ARRAY_NAME $ARRAY_TYPE $XML_TARGET | grep '@android\|@string\|@color\|@drawable' | wc -l) -gt 0 ]; then
					grep -ne ''$ARRAY_NAME'' $XML_TARGET 
				fi
		      done >> $XML_CACHE_LOG;;
esac
write_log_error "purple"

# Count array items
if [ "$XML_TYPE" == "arrays.xml" ]; then
	cat $XML_TARGET | grep 'name=' | while read array_count; do
		ARRAY_NAME=$(echo $array_count | cut -d'>' -f1 | cut -d'"' -f2)
		if [ $(cat $ARRAY_ITEM_LIST | grep 'application="'$APK'" name="'$ARRAY_NAME'"' | wc -l) -gt 0 ]; then
			ARRAY_TYPE=$(echo $array_count | cut -d' ' -f1 | cut -d'<' -f2)
			DIFF_ARRAY_COUNT=$(cat $ARRAY_ITEM_LIST | grep 'application="'$APK'" name="'$ARRAY_NAME'"' | awk '{print $4}' | cut -d'"' -f2 | cut -d'>' -f1)
			TARGET_ARRAY_COUNT=$(arrays_count_items $ARRAY_NAME $ARRAY_TYPE $XML_TARGET)
			if [ "$TARGET_ARRAY_COUNT" != "$DIFF_ARRAY_COUNT" ]; then
				ARRAY=$(grep -ne ''$ARRAY_NAME'' $XML_TARGET)
				echo "$ARRAY - has $TARGET_ARRAY_COUNT items, should be $DIFF_ARRAY_COUNT items" >> $XML_CACHE_LOG
			fi
		fi
	done
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

#########################################################################################################
# PULL LANGUAGES
#########################################################################################################
pull_lang () {
if [ "$PULL_FLAG" != "" ]; then
	if [ $PULL_FLAG == "force" ]; then
		rm -rf $MAIN_DIR/languages/$LANG_TARGET; sleep 1; sync
	fi
fi
if [ -d $MAIN_DIR/languages/$LANG_TARGET ]; then
	OLD_GIT=$(grep "url = *" $MAIN_DIR/languages/$LANG_TARGET/.git/config | cut -d' ' -f3)
	if [ "$LANG_GIT" != "$OLD_GIT" ]; then
		echo -e "${txtblu}\nNew repository detected, removing old repository...\n$OLD_GIT ---> $LANG_GIT${txtrst}"
		rm -rf $MAIN_DIR/languages/$LANG_TARGET
	fi
fi

echo -e "${txtblu}\nSyncing $LANG_NAME MIUI$LANG_VERSION${txtrst}"
if [ -e $MAIN_DIR/languages/$LANG_TARGET ]; then
     	cd $MAIN_DIR/languages/$LANG_TARGET; git pull origin $LANG_BRANCH; cd ../../..
else
     	git clone $LANG_GIT  -b $LANG_BRANCH $MAIN_DIR/languages/$LANG_TARGET
fi
}

# Sync required resources (languages.xml, ignorelists etc.)
sync_resources () {
echo -e "${txtblu}\nSyncing resources${txtrst}"
if [ "$RESOURCES_GIT" != "" ]; then
	if [ -d $RES_DIR/.git ]; then
		OLD_GIT=$(grep "url = *" $RES_DIR/.git/config | cut -d' ' -f3)
		if [ "$RESOURCES_GIT" != "$OLD_GIT" ]; then
			echo -e "${txtblu}\nNew resources repository detected, removing old repository...\n$OLD_GIT ---> $RESOURCES_GIT${txtrst}"
			rm -rf $RES_DIR
		fi
	fi
	if [ -d $RES_DIR/.git ]; then
		OLD_BRANCH=$(grep 'branch "' $RES_DIR/.git/config | cut -d'"' -f2 | cut -d'[' -f2 | cut -d']' -f1)
		if [ "$RESOURCES_BRANCH" != "$OLD_BRANCH" ]; then
			echo -e "${txtblu}\nNew resources branch detected, removing old repository...\n$OLD_BRANCH ---> $RESOURCES_BRANCH${txtrst}"
			rm -rf $RES_DIR
		fi
	fi
	if [ -d $RES_DIR ]; then
		cd $RES_DIR
		git pull origin $RESOURCES_BRANCH
		cd $MAIN_DIR
	else
		git clone $RESOURCES_GIT -b $RESOURCES_BRANCH $RES_DIR
	fi
fi
source $ARRAY_TOOLS
if [ -e $RESOURCES_SYNC_COUNT ]; then
	RES_SYNCS=$(expr $(cat $RESOURCES_SYNC_COUNT) + 1)
	if [ "$RES_SYNCS" == "16" ]; then
		bash $RES_DIR/sync_resources.sh "$RESOURCES_BRANCH"
		RES_SYNCS=1
	fi
	echo "$RES_SYNCS" > $RESOURCES_SYNC_COUNT
else
	echo "1" > $RESOURCES_SYNC_COUNT
fi
}

# Fix old languages format (trigger with --fix_languages)
clean_up () {
sync_resources
cat $LANG_XML | grep '<language enabled=' | while read all_line; do
	CHANGE_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
	CHANGE_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
	CHANGE_ISO=$(echo $all_line | awk '{print $5}' | cut -d'"' -f2) 
	if [ -d $MAIN_DIR/languages/$CHANGE_ISO ]; then
		mv $MAIN_DIR/languages/$CHANGE_ISO $MAIN_DIR/languages/"$CHANGE_NAME"_"$CHANGE_VERSION"
	fi
done
}

#########################################################################################################
# ARGUMENTS
#########################################################################################################
show_argument_help () { 
echo 
echo "MA-XML-CHECK $VERSION"
echo "By Redmaner"
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
echo "		--remove [cache|logs|all|language]	Removes caches, logs or language(s)"
echo 
exit 
}

if [ $# -gt 0 ]; then
     	if [ $1 == "--help" ]; then
          	show_argument_help
     	elif [ $1 == "--check" ]; then
		build_cache
		sync_resources
            	DEBUG_MODE=lang
            	case "$2" in
		  	all) if [ "$3" == "full" ]; then
                                 DEBUG_MODE=full
                             elif [ "$3" == "double" ]; then
                               	 DEBUG_MODE=double
                             fi; 
			     LINE_NR=$(cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | wc -l)
			     LAST_URL=$(cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | sed -n "$LINE_NR"p | awk '{print $6}' | cut -d'"' -f2)
			     cat $LANG_XML | grep '<language check=' | grep -v '<language check="false"' | while read all_line; do
					LANG_CHECK=$(echo $all_line | awk '{print $2}' | cut -d'"' -f2)
					LANG_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
					LANG_ISO=$(echo $all_line | awk '{print $5}' | cut -d'"' -f2)
				      	LANG_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
					LANG_URL=$(echo $all_line | awk '{print $6}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
					UNTRANSLATEABLE_LIST=$RES_DIR/MIUI"$LANG_VERSION"_ignorelist.xml
					ARRAY_ITEM_LIST=$RES_DIR/MIUI"$LANG_VERSION"_arrays_items.xml
                        		init_xml_check
   			     done;;
			  *) if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
			     fi
			     if [ "`cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"'| wc -l`" -gt 0 ]; then
					LANG_CHECK=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $2}' | cut -d'"' -f2)
					LANG_VERSION=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $3}' | cut -d'"' -f2)
					LANG_ISO=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $5}' | cut -d'"' -f2)
				      	LANG_NAME=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $4}' | cut -d'"' -f2)
					LANG_URL=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $6}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
					UNTRANSLATEABLE_LIST=$RES_DIR/MIUI"$LANG_VERSION"_ignorelist.xml
					ARRAY_ITEM_LIST=$RES_DIR/MIUI"$LANG_VERSION"_arrays_items.xml
                                 	init_xml_check
                             else
					echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			     fi;;
           	esac
		clear_cache			
     	elif [ $1 == "--pull" ]; then
		sync_resources
            	case "$2" in
			all) cat $LANG_XML | grep 'language check=' | grep -v '<language check="false"' | while read all_line; do
					if [ "$3" != "" ]; then
   						if [ $3 == "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					LANG_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
					LANG_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
					LANG_GIT=$(echo $all_line | awk '{print $7}' | cut -d'"' -f2)
					LANG_BRANCH=$(echo $all_line | awk '{print $8}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
                        		pull_lang
   			     done;;
			  *) if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
			     elif [ "$3" == "force" ]; then
					echo -e "${txtred}\nError: Specifiy MIUI version before force flag${txtrst}"; exit
			     fi
			     if [ "`cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | wc -l`" -gt 0 ]; then
					if [ "$4" != "" ]; then
   						if [ $4 = "force" ]; then
							PULL_FLAG="force"
						fi
					fi
					LANG_VERSION=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $3}' | cut -d'"' -f2)
					LANG_NAME=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"' | awk '{print $4}' | cut -d'"' -f2)
					LANG_GIT=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"'| awk '{print $7}' | cut -d'"' -f2)
					LANG_BRANCH=$(cat $LANG_XML | grep 'name="'$2'"' | grep 'miui="'$3'"'| awk '{print $8}' | cut -d'"' -f2)
					LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
                        		pull_lang 
                             else
					echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			     fi;;
           	esac
     	elif [ $1 == "--remove" ]; then
            	if [ "$2" != " " ]; then
                 	case "$2" in
                             logs) rm -f $LOG_DIR/XML_*.html;;
			    cache) ls -a | grep ".cache" | while read found_cache; do
					rm -rf $found_cache
				   done;;
                              all) rm -rf $MAIN_DIR/languages; mkdir -p $MAIN_DIR/languages;;
				*) sync_resources
				   if [ "$3" == "" ]; then
				    	echo -e "${txtred}\nError: Specifiy MIUI version${txtrst}"; exit
				   fi
				   if [ "`cat $LANG_XML | grep 'name="'$2'"' | 'miui="'$3'"' | wc -l`" -gt 0 ]; then
						LANG_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
						LANG_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
						LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
                        			rm -rf $MAIN_DIR/languages/$LANG_TARGET 
                             	   else
						echo -e "${txtred}\nLanguage not supported or language not specified${txtrst}"; exit
			           fi;;
                 	esac 
            	fi
	elif [ $1 == "--server" ]; then
		build_cache
		sync_resources
            	DEBUG_MODE=double
		LINE_NR=$(cat $LANG_XML | grep '<language check=' | grep -v '<language check="false"' | wc -l)
		LAST_URL=$(cat $LANG_XML | grep '<language check=' | grep -v '<language check="false"' | sed -n "$LINE_NR"p | awk '{print $6}' | cut -d'"' -f2)
		cat $LANG_XML | grep '<language check=' | grep -v '<language check="false"' | while read all_line; do
			LANG_CHECK=$(echo $all_line | awk '{print $2}' | cut -d'"' -f2)
			LANG_VERSION=$(echo $all_line | awk '{print $3}' | cut -d'"' -f2)
			LANG_ISO=$(echo $all_line | awk '{print $5}' | cut -d'"' -f2)
			LANG_NAME=$(echo $all_line | awk '{print $4}' | cut -d'"' -f2)
			LANG_URL=$(echo $all_line | awk '{print $6}' | cut -d'"' -f2)
			LANG_GIT=$(echo $all_line | awk '{print $7}' | cut -d'"' -f2)
			LANG_BRANCH=$(echo $all_line | awk '{print $8}' | cut -d'"' -f2)
			LANG_TARGET=""$LANG_NAME"_"$LANG_VERSION""
			UNTRANSLATEABLE_LIST=$RES_DIR/MIUI"$LANG_VERSION"_ignorelist.xml
			ARRAY_ITEM_LIST=$RES_DIR/MIUI"$LANG_VERSION"_arrays_items.xml
                        pull_lang 
                        init_xml_check
   		done
     	elif [ $1 == "--fix_languages" ]; then
		clean_up
     	else
            	show_argument_help; exit
     	fi
else
     	show_argument_help; exit
fi
