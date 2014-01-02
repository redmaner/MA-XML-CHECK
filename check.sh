#!/bin/bash
case `uname -s` in
    Darwin) 
     	txtrst='\033[0m' # Color off
        txtgrn='\033[0;32m' # Green
        txtblu='\033[0;34m' # Blue
        ;;
    *)
        txtrst='\e[0m' # Color off
        txtgrn='\e[0;32m' # Green
        txtblu='\e[0;36m' # Blue
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

LANG_TARGETS=$MAIN_DIR/.cache/language.targets
LANG_NAMES=$MAIN_DIR/languages/language.names
XML_TARGETS_ARRAYS=$MAIN_DIR/.cache/xml.targets.arrays
XML_TARGETS_STRINGS=$MAIN_DIR/.cache/xml.targets.strings
XML_TARGETS_PLURALS=$MAIN_DIR/.cache/xml.targets.plurals
XML_TARGET_STRIPPED=$MAIN_DIR/.cache/xml.target.stripped
DOUBLE_RESULT=$MAIN_DIR/.cache/xml.double.result
APOSTROPHE_RESULT=$MAIN_DIR/.cache/xml.apostrophe.result
XML_CACHE_LOG=$MAIN_DIR/.cache/XML_CACHE_LOG

clear_cache () {
rm -rf $MAIN_DIR/.cache
mkdir -p $MAIN_DIR/.cache
}

clean_cache () {
rm -f $XML_TARGETS_STRIPPED
rm -f $DOUBLE_RESULT
rm -f $OPOSTROPHE_RESULT
rm -f $XML_CACHE_LOG
}

debug_mode () {
if [ "$DEBUG_MODE" = "full" ]; then
     	XML_LOG=$MAIN_DIR/.cache/XML_CHECK_FULL
elif [ "$DEBUG_MODE" = "double" ]; then
       	XML_LOG_FULL=$MAIN_DIR/.cache/XML_CHECK_FULL
       	LOG_TARGET=$XML_LOG_FULL; update_log
       	XML_LOG=$MAIN_DIR/.cache/XML_$LANG_TARGET
else
     	XML_LOG=$MAIN_DIR/.cache/XML_$LANG_TARGET
fi
LOG_TARGET=$XML_LOG; update_log
}

update_log () {
DATE=$(date +"%m-%d-%Y %H:%M:%S")
if [ -e $LOG_TARGET ]; then
     	LINE_NR=$(wc -l $LOG_TARGET | cut -d' ' -f1)
     	if [ "$(sed -n "$LINE_NR"p $LOG_TARGET)" = '<!-- Start of log --><script type="text/plain">' ]; then 
           	echo '</script></font><font id="green">No errors found in this repository!</font>' >> $LOG_TARGET
           	echo '</script><font id="header"><br><br>Checked '$LANG_NAME' ('$LANG_TARGET') repository on '$DATE'</font>' >> $LOG_TARGET
           	echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
     	else
           	echo '</script></font><font id="header"><br><br>Checked '$LANG_NAME' ('$LANG_TARGET') repository on '$DATE'</font>' >> $LOG_TARGET
           	echo '<!-- Start of log --><script type="text/plain">' >> $LOG_TARGET
     	fi
else
     	cat >> $LOG_TARGET << EOF
<!DOCTYPE html>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<html>
<head>
<style>
script {
  display: block;
  padding: auto;
  white-space: pre;
}
#header {
  font-weight: bold;
  color: #000000;
}
#black {
  color: #000000;
}
#green {
  color: #006633;
}
#red {
  color: #ff0000;
}
#blue {
  color: #0000ff;
}
#orange {
  color: #CC6633;
}
#brown {
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
</style></head>
<body id="red">
<br><br>
<table border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><font id="green">Green text</font></td>
<td height="auto" width="220px"><font id="black">No errors found</font><td>
</table>
<table border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><font id="red">Red text</font></td>
<td height="auto" width="220px"><font id="black">Parser error</font><td>
</table>
<table border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><font id="orange">Orange text</font></td>
<td height="auto" width="220px"><font id="black">Double strings</font><td>
</table>
<table  border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><font id="brown">Brown text</font></td>
<td height="auto" width="220px"><font id="black">Apostrophe syntax error</font><td>
</table>
<table border="0" cellpadding="0" cellspacing="0">
<td height="auto" width="120px"><font id="blue">Blue text</font></td>
<td height="auto" width="220px"><font id="black">'+' outside of tags</font><td>
</table>
<font id="header"><br><br>Checked $LANG_NAME ($LANG_TARGET) repository on $DATE<br></font>
<!-- Start of log --><script type="text/plain">
EOF
fi
}

check_log () {
LINE_NR=$(wc -l $XML_LOG | cut -d' ' -f1)
if [ "$(sed -n "$LINE_NR"p $XML_LOG)" = '<!-- Start of log --><script type="text/plain">' ]; then 
     	echo '</script><font id="green">No errors found in this repository!</font>' >> $XML_LOG
fi
if [ $DEBUG_MODE = "full" ]; then
     	if [ "$LANG_TARGET" = "$LAST_TARGET" ]; then
          	rm -f $LOG_DIR/XML_CHECK_FULL.html
          	cp $XML_LOG $LOG_DIR/XML_CHECK_FULL.html
          	echo -e "${txtgrn}All languages checked, log at logs/XML_CHECK_FULL.html${txtrst}"
     	fi
elif [ $DEBUG_MODE = "double" ]; then
     	cp $XML_LOG $LOG_DIR/XML_$LANG_TARGET.html
    	echo -e "${txtgrn}$LANG_NAME ($LANG_TARGET) checked, log at logs/XML_$LANG_TARGET.html${txtrst}"
     	if [ "$LANG_TARGET" = "$LAST_TARGET" ]; then
          	LINE_NR=$(wc -l $XML_LOG_FULL | cut -d' ' -f1)
          	if [ "$(sed -n "$LINE_NR"p $XML_LOG_FULL)" = '<!-- Start of log --><script type="text/plain">' ]; then
               		echo '</script><font id="green">No errors found in this repository!</font>' >> $XML_LOG_FULL
          	fi
          	cp $XML_LOG_FULL $LOG_DIR/XML_CHECK_FULL.html
          	echo -e "${txtgrn}All languages checked, log at logs/XML_CHECK_FULL.html${txtrst}"
     	fi
else
     	rm -f $LOG_DIRl/XML_$LANG_TARGET.html
     	cp $XML_LOG $LOG_DIR/XML_$LANG_TARGET.html
     	echo -e "${txtgrn}$LANG_NAME ($LANG_TARGET) checked, log at logs/XML_$LANG_TARGET.html${txtrst}"
fi
}

check_xml_full () {
ls $MAIN_DIR/languages > $LANG_TARGETS
LAST_TARGET=$(sed -n "$(wc -l $LANG_TARGETS | cut -d' ' -f1)"p $LANG_TARGETS)
cat $LANG_TARGETS | while read all_line; do
    	init_xml_check "$all_line" 
done
}

init_xml_check () {
LANG=$1
LANG_TARGET=$(echo $LANG)
LANG_NAME=$(cat $LANG_NAMES | grep ''$LANG'=' | cut -d'=' -f2)

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
fi
}

start_xml_check () {
cat $XML_TARGETS_ARRAYS | while read all_line; do
    	$CHECK_MODE "$all_line" arrays
done; clean_cache
cat $XML_TARGETS_STRINGS | while read all_line; do
    	$CHECK_MODE "$all_line" strings
done; clean_cache
cat $XML_TARGETS_PLURALS | while read all_line; do
    	$CHECK_MODE "$all_line" plurals
done; clean_cache
check_log
}

xml_check () {
XML=$1
XML_TARGET=$(echo $XML)
XML_TYPE=$2

if [ -e "$XML_TARGET" ]; then
     	echo -e '</script><font id="black"><br>'$XML_TARGET'</font><script type="text/plain">' >> $XML_LOG

     	# Check for XML Parser errors
     	xmllint --noout $XML_TARGET 2>> $XML_LOG

     	# Check for doubles in strings.xml
     	if [ "$XML_TYPE" = "strings" ]; then
          	echo '</script><font id="orange"><script type="text/plain">' >> $XML_LOG
          	cat $XML_TARGET | while read all_line; do grep "<string" | cut -d'>' -f1; done > $XML_TARGET_STRIPPED
          	sort $XML_TARGET_STRIPPED | uniq --repeated > $DOUBLE_RESULT
          	cat $DOUBLE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_LOG
          	if [ "$(sed -n "$(wc -l $XML_LOG | cut -d' ' -f1)"p $XML_LOG)" = '</script><font id="orange"><script type="text/plain">' ]; then
               		sed -i '$ d' $XML_LOG
          	fi
     	fi

     	# Check for apostrophe errors in strings.xml
     	echo '</script></font><font id="brown"><script type="text/plain">' >> $XML_LOG
     	grep "<string" $XML_TARGET | grep -v '>"' > $XML_TARGET_STRIPPED
     	if [ -e $XML_TARGET_STRIPPED ]; then
          	grep "'" $XML_TARGET_STRIPPED | grep -v "'\''" > $APOSTROPHE_RESULT
          	if [ -e $APOSTROPHE_RESULT ]; then
               		cat $APOSTROPHE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_LOG
          	fi
     	fi
     	if [ "$(sed -n "$(wc -l $XML_LOG | cut -d' ' -f1)"p $XML_LOG)" = '</script></font><font id="brown"><script type="text/plain">' ]; then
          	sed -i '$ d' $XML_LOG
     	fi

     	# Check for '+' at the beginning of a line, outside <string>
     	echo '</script></font><font id="blue"><script type="text/plain">' >> $XML_LOG
     	grep -ne "+ * <s" $XML_TARGET >> $XML_LOG 
     	if [ "$(sed -n "$(wc -l $XML_LOG | cut -d' ' -f1)"p $XML_LOG)" = '</script></font><font id="blue"><script type="text/plain">' ]; then
          	sed -i '$ d' $XML_LOG
     	fi; 

     	# Clean up log if there are no errors
     	if [ "$(sed -n "$(wc -l $XML_LOG | cut -d' ' -f1)"p $XML_LOG)" = '</script><font id="black"><br>'$XML_TARGET'</font><script type="text/plain">' ]; then 
          	sed -i '$ d' $XML_LOG
     	fi
fi
}

xml_check_double () {
XML=$1
XML_TARGET=$(echo $XML)
XML_TYPE=$2

rm -f $XML_CACHE_LOG
if [ -e "$XML_TARGET" ]; then
     	echo -e '</script><font id="black"><br>'$XML_TARGET'</font><script type="text/plain">' >> $XML_CACHE_LOG

     	# Check for XML Parser errors
     	xmllint --noout $XML_TARGET 2>> $XML_CACHE_LOG

     	# Check for doubles in strings.xml
     	if [ "$XML_TYPE" = "strings" ]; then
          	echo '</script><font id="orange"><script type="text/plain">' >> $XML_CACHE_LOG
          	cat $XML_TARGET | while read all_line; do grep "<string" | cut -d'>' -f1; done > $XML_TARGET_STRIPPED
          	sort $XML_TARGET_STRIPPED | uniq --repeated > $DOUBLE_RESULT
          	cat $DOUBLE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_CACHE_LOG
          	if [ "$(sed -n "$(wc -l $XML_CACHE_LOG | cut -d' ' -f1)"p $XML_CACHE_LOG)" = '</script><font id="orange"><script type="text/plain">' ]; then
               		sed -i '$ d' $XML_CACHE_LOG
          	fi
     	fi

     	# Check for apostrophe errors in strings.xml
        echo '</script></font><font id="brown"><script type="text/plain">' >> $XML_CACHE_LOG
        grep "<string" $XML_TARGET > $XML_TARGET_STRIPPED
        grep -v '>"' $XML_TARGET_STRIPPED > $APOSTROPHE_RESULT
        if [ -e $APOSTROPHE_RESULT ]; then
        	grep "'" $APOSTROPHE_RESULT > $XML_TARGET_STRIPPED
               	grep -v "'\''" $XML_TARGET_STRIPPED > $APOSTROPHE_RESULT
               	if [ -e $APOSTROPHE_RESULT ]; then
                   	cat $APOSTROPHE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_CACHE_LOG
               	fi
        fi
        if [ "$(sed -n "$(wc -l $XML_CACHE_LOG | cut -d' ' -f1)"p $XML_CACHE_LOG)" = '</script></font><font id="brown"><script type="text/plain">' ]; then
               	sed -i '$ d' $XML_CACHE_LOG
        fi

     	# Check for '+' at the beginning of a line, outside <string>
     	echo '</script></font><font id="blue"><script type="text/plain">' >> $XML_CACHE_LOG
     	grep -ne "+ * <s" $XML_TARGET >> $XML_CACHE_LOG
     	if [ "$(sed -n "$(wc -l $XML_CACHE_LOG | cut -d' ' -f1)"p $XML_CACHE_LOG)" = '</script></font><font id="blue"><script type="text/plain">' ]; then
          	sed -i '$ d' $XML_CACHE_LOG
     	fi; 

     	# Clean up log if there are no errors
     	if [ "$(sed -n "$(wc -l $XML_CACHE_LOG | cut -d' ' -f1)"p $XML_CACHE_LOG)" = '</script><font id="black"><br>'$XML_TARGET'</font><script type="text/plain">' ]; then 
          	sed -i '$ d' $XML_CACHE_LOG
     	fi
     	cat $XML_CACHE_LOG >> $XML_LOG_FULL
     	cat $XML_CACHE_LOG >> $XML_LOG
fi
}

# Pull / remove langs
pull_lang () {
LANG=$1
ISO=$2
REPO=$3
echo -e "${txtblu}\nSyncing $LANG${txtrst}"
if [ -e $MAIN_DIR/languages/$ISO ]; then
     	cd $MAIN_DIR/languages/$ISO; git pull; cd ../../..
else
     	git clone $REPO $MAIN_DIR/languages/$ISO
fi
}

remove_langs () {
ls $MAIN_DIR/languages > $LANG_TARGETS
LAST_TARGET=$(sed -n "$(wc -l $LANG_TARGETS | cut -d' ' -f1)"p $LANG_TARGETS)
cat $LANG_TARGETS | while read all_line; do
    	if [ -d $MAIN_DIR/languages/$all_line ]; then
         	rm -rf $MAIN_DIR/languages/$all_line
    	fi 
done
}


# Specific arguments
show_argument_help () { 
echo 
echo "MIUIAndroid.com language repo XML check"
echo 
echo "Usage: check.sh [option]"
echo 
echo " [option]:"
echo " 		--help					This help"
echo "		--check [your_language]	[full/double]	Check specified language"
echo "							If [your_language] is 'all', then all languages will be checked"
echo "							If third argument is not defined, all languages will be logged in seperate files"
echo "							If third argument is 'full', all languages will be logged in one file"
echo "							If third argument is 'double', all languages will be logged in one file and in seperate files"
echo "		--pull [your_language]			Sync specified language"
echo "							If [your_language] is 'all', then all languages will be synced/updated"
echo "		--cleanup [logs|languages|all]		Removes logs and/or languages"
echo 
exit 
}

if [ $# -gt 0 ]; then
     	if [ $1 == "--help" ]; then
          	show_argument_help
     	elif [ $1 == "--check" ]; then
            	clear_cache
            	DEBUG_MODE=lang
            	CHECK_MODE=xml_check
            	case "$2" in
                       all) if [ "$3" = "full" ]; then
                                 DEBUG_MODE=full
                            elif [ "$3" = "double" ]; then
                                   DEBUG_MODE=double
                                   CHECK_MODE=xml_check_double
                            fi; check_xml_full;;
                    arabic) init_xml_check "ar";; 
      brazilian-portuguese) init_xml_check "pt-rBR";;
                 bulgarian) init_xml_check "bg";;
                     czech) init_xml_check "cs";;
                    danish) init_xml_check "da";;
                     dutch) init_xml_check "nl";; 
                   english) init_xml_check "en";; 
                   finnish) init_xml_check "fi";;
                    french) init_xml_check "fr";;
                    german) init_xml_check "de";; 
                     greek) init_xml_check "el";; 
                 hungarian) init_xml_check "hu";; 
                indonesian) init_xml_check "in";; 
                   italian) init_xml_check "it";; 
                    korean) init_xml_check "ko";; 
                 malaysian) init_xml_check "ms-rMY";;
                 norwegian) init_xml_check "nb";; 
                    polish) init_xml_check "pl";;
                  romanian) init_xml_check "ro";; 
                   russian) init_xml_check "ru";;
                    slovak) init_xml_check "sk";; 
                   spanish) init_xml_check "es";;
                   swedish) init_xml_check "sv";;
                      thai) init_xml_check "th";; 
                   turkish) init_xml_check "tr";; 
                 ukrainian) init_xml_check "uk";; 
                vietnamese) init_xml_check "vi";; 
                         *) echo "Language not supported or language not specified"; exit;;
           	esac
     	elif [ $1 == "--pull" ]; then
            	case "$2" in
                       all) pull_lang "Arabic" "ar" "git@github.com:MIUI-Palestine/MIUIPalestine_V5_Arabic_XML.git"
                            pull_lang "Brazilian-Portuguese" "pt-rBR" "git@bitbucket.org:miuibrasil/ma-xml-5.0-portuguese-brazilian.git"
                            pull_lang "Bulgarian" "bg" "git@github.com:ingbrzy/MA-XML-5.0-BULGARIAN.git"
                            pull_lang "Czech" "cs" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-CZECH.git"
                            pull_lang "Danish" "da" "git@github.com:1982Strand/XML_MIUI-v5_Danish.git"
                            pull_lang "Dutch" "nl" "git@github.com:Redmaner/MA-XML-5.0-DUTCH.git"
                            pull_lang "English" "en" "git@github.com:iBotPeaches/MIUIAndroid_XML_v5.git"
                            pull_lang "Finnish" "fi" "git@github.com:ingbrzy/MA-XML-5.0-FINNISH.git"
                            pull_lang "French" "fr" "git@github.com:ingbrzy/ma-xml-5.0-FRENCH.git"
                            pull_lang "German" "de" "git@github.com:Bitti09/ma-xml-5.0-german.git"
                            pull_lang "Greek" "el" "git@bitbucket.org:finner/ma-xml-5.0-greek.git"
                            pull_lang "Hungarian" "hu" "git@github.com:vagyula1/miui-v5-hungarian-translation-for-miuiandroid.git"
                            pull_lang "Indonesian" "in" "git@github.com:ingbrzy/MA-XML-5.0-INDONESIAN.git"
                            pull_lang "Italian" "it" "git@bitbucket.org:Mish/miui_v5_italy.git"
                            pull_lang "Korean" "ko" "git@github.com:nosoy1/ma-xml-5.0-korean.git"
                            pull_lang "Malaysian" "ms-rMY" "git@github.com:ingbrzy/MA-XML-5.0-MALAY.git"
                            pull_lang "Norwegian" "nb" "git@github.com:ingbrzy/MA-XML-5.0-NORWEGIAN.git"
                            pull_lang "Polish" "pl" "git@github.com:Acid-miuipolskapl/XML_MIUI-v5.git"
                            pull_lang "Romanian" "ro" "git@github.com:ingbrzy/MA-XML-5.0-ROMANIAN.git"
                            pull_lang "Russian" "ru" "git@github.com:KDGDev/miui-v5-russian-translation-for-miuiandroid.git"
                            pull_lang "Slovak" "sk" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-SLOVAK.git"
                            pull_lang "Spanish" "es" "git@github.com:ingbrzy/MA-XML-5.0-SPANISH.git"
                            pull_lang "Swedish" "sv" "git@github.com:ingbrzy/ma-xml-5.0-SWEDISH.git"
                            pull_lang "Thai" "th" "git@github.com:rcset/MIUIAndroid_XML_v5_TH.git"
                            pull_lang "Turkish" "tr" "git@github.com:ingbrzy/MA-XML-5.0-TURKISH.git"
                            pull_lang "Ukrainian" "uk" "git@github.com:KDGDev/miui-v5-ukrainian-translation-for-miuiandroid.git"
                            pull_lang "Vietnamese" "vi" "git@github.com:HoangTuBot/MA-xml-v5-vietnam.git";;
                    arabic) pull_lang "Arabic" "ar" "git@github.com:MIUI-Palestine/MIUIPalestine_V5_Arabic_XML.git";;
      brazilian-portuguese) pull_lang "Brazilian-Portuguese" "pt-rBR" "git@bitbucket.org:miuibrasil/ma-xml-5.0-portuguese-brazilian.git";;
                 bulgarian) pull_lang "Bulgarian" "bg" "git@github.com:ingbrzy/MA-XML-5.0-BULGARIAN.git";;
                     czech) pull_lang "Czech" "cs" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-CZECH.git";;
                    danish) pull_lang "Danish" "da" "git@github.com:1982Strand/XML_MIUI-v5_Danish.git";;
                     dutch) pull_lang "Dutch" "nl" "git@github.com:Redmaner/MA-XML-5.0-DUTCH.git";;
                   english) pull_lang "English" "en" "git@github.com:iBotPeaches/MIUIAndroid_XML_v5.git";;
                   finnish) pull_lang "Finnish" "fi" "git@github.com:ingbrzy/MA-XML-5.0-FINNISH.git";;
                    french) pull_lang "French" "fr" "git@github.com:ingbrzy/ma-xml-5.0-FRENCH.git";;
                    german) pull_lang "German" "de" "git@github.com:Bitti09/ma-xml-5.0-german.git";;
                     greek) pull_lang "Greek" "el" "git@bitbucket.org:finner/ma-xml-5.0-greek.git";;
                 hungarian) pull_lang "Hungarian" "hu" "git@github.com:vagyula1/miui-v5-hungarian-translation-for-miuiandroid.git";;
                indonesian) pull_lang "Indonesian" "in" "git@github.com:ingbrzy/MA-XML-5.0-INDONESIAN.git";;
                   italian) pull_lang "Italian" "it" "git@bitbucket.org:Mish/miui_v5_italy.git";;
                    korean) pull_lang "Korean" "ko" "git@github.com:nosoy1/ma-xml-5.0-korean.git";;
                 malaysian) pull_lang "Malaysian" "ms-rMY" "git@github.com:ingbrzy/MA-XML-5.0-MALAY.git";;
                 norwegian) pull_lang "Norwegian" "nb" "git@github.com:ingbrzy/MA-XML-5.0-NORWEGIAN.git";;
                    polish) pull_lang "Polish" "pl" "git@github.com:Acid-miuipolskapl/XML_MIUI-v5.git";;
                  romanian) pull_lang "Romanian" "ro" "git@github.com:ingbrzy/MA-XML-5.0-ROMANIAN.git";;
                   russian) pull_lang "Russian" "ru" "git@github.com:KDGDev/miui-v5-russian-translation-for-miuiandroid.git";;
                    slovak) pull_lang "Slovak" "sk" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-SLOVAK.git";;
                   spanish) pull_lang "Spanish" "es" "git@github.com:ingbrzy/MA-XML-5.0-SPANISH.git";;
                   swedish) pull_lang "Swedish" "sv" "git@github.com:ingbrzy/ma-xml-5.0-SWEDISH.git";;
                      thai) pull_lang "Thai" "th" "git@github.com:rcset/MIUIAndroid_XML_v5_TH.git";;
                   turkish) pull_lang "Turkish" "tr" "git@github.com:ingbrzy/MA-XML-5.0-TURKISH.git";;
                 ukrainian) pull_lang "Ukrainian" "uk" "git@github.com:KDGDev/miui-v5-ukrainian-translation-for-miuiandroid.git";;
                vietnamese) pull_lang "Vietnamese" "vi" "git@github.com:HoangTuBot/MA-xml-v5-vietnam.git";;
                         *) echo "Language not supported or language not specified"; exit;;
           	esac
     	elif [ $1 == "--cleanup" ]; then
            	if [ "$2" != " " ]; then
                 	case "$2" in
                             logs) rm -f $LOG_DIR/XML_*.html;;
                        languages) remove_langs;;
                              all) rm -f $LOG_DIR/XML_*.html
                                   remove langs;;
                 	esac 
            	else
                 	remove_langs
                 	rm -f $LOG_DIR/XML_*.html
            	fi
     	else
            	show_argument_help
     	fi
else
     	clear_cache
     	DEBUG_MODE=full
     	CHECK_MODE=xml_check
     	check_xml_full
fi
