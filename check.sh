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

LANG_TARGETS=/home/translators.xiaomi.eu/scripts/.cache/language.targets
XML_TARGETS_ARRAYS=/home/translators.xiaomi.eu/scripts/.cache/xml.targets.arrays
XML_TARGETS_STRINGS=/home/translators.xiaomi.eu/scripts/.cache/xml.targets.strings
XML_TARGETS_PLURALS=/home/translators.xiaomi.eu/scripts/.cache/xml.targets.plurals
XML_TARGET_STRIPPED=/home/translators.xiaomi.eu/scripts/.cache/xml.target.stripped
DOUBLE_RESULT=/home/translators.xiaomi.eu/scripts/.cache/xml.double.result

clear_cache () {
rm -rf /home/translators.xiaomi.eu/scripts/.cache
mkdir -p /home/translators.xiaomi.eu/scripts/.cache
mkdir -p /home/translators.xiaomi.eu/public_html/logs
}

debug_mode () {
if [ "$DEBUG_MODE" = "full" ]; then
     XML_LOG=/home/translators.xiaomi.eu/scripts/.cache/XML_CHECK_FULL
else
     XML_LOG=/home/translators.xiaomi.eu/scripts/.cache/XML_$LANG_TARGET
fi
DATE=$(date +"%m-%d-%Y %H:%M:%S")
if [ -e $XML_LOG ]; then
     LINE_NR=$(wc -l $XML_LOG | cut -d' ' -f1)
     if [ "$(sed -n "$LINE_NR"p $XML_LOG)" = "<!-- Start of log --><script>" ]; then 
           echo "</script><font color="#006633">No errors found in this repository!</font>" >> $XML_LOG
           echo "</script><font color="#000000"><b><br><br>Checked $LANG_TARGET REPO on $DATE</b><br></font>" >> $XML_LOG
           echo "<!-- Start of log --><script>" >> $XML_LOG
     else
           echo "</script><font color="#000000"><b><br><br>Checked $LANG_TARGET REPO on $DATE</b><br></font>" >> $XML_LOG
           echo "<!-- Start of log --><script>" >> $XML_LOG
     fi
else
     cat >> $XML_LOG << EOF
<!DOCTYPE html>
<html>
<head>
<style>
script {
  display: block;
  padding: auto;
}
</style></head>
<body text="#ff0000">
<font color="#000000"><b><br><br>Checked $LANG_TARGET REPO on $DATE</b><br></font>
<!-- Start of log --><script>
EOF
fi

}

check_log () {
LINE_NR=$(wc -l $XML_LOG | cut -d' ' -f1)
if [ "$(sed -n "$LINE_NR"p $XML_LOG)" = "<!-- Start of log --><script>" ]; then 
     echo "</script><font color="#006633">No errors found in this repository!</font>" >> $XML_LOG
fi
if [ $DEBUG_MODE = "full" ]; then
     rm -f /home/translators.xiaomi.eu/public_html/XML_CHECK_FULL.html
     cp $XML_LOG /home/translators.xiaomi.eu/public_html/XML_CHECK_FULL.html
     echo -e "${txtgrn}$LANG_TARGET checked, log at logs/XML_CHECK_FULL.html${txtrst}"
else
     rm -f /home/translators.xiaomi.eu/public_html/XML_$LANG_TARGET.html
     cp $XML_LOG /home/translators.xiaomi.eu/public_html/XML_$LANG_TARGET.html
     echo -e "${txtgrn}$LANG_TARGET checked, log at logs/XML_$LANG_TARGET.html${txtrst}"
fi
}

check_xml_full () {
ls /home/translators.xiaomi.eu/scripts/languages > $LANG_TARGETS
cat $LANG_TARGETS | while read all_line; do
    init_xml_check "$all_line" 
done
}

init_xml_check () {
LANG=$1
LANG_TARGET=$(echo $LANG)

if [ -d /home/translators.xiaomi.eu/scripts/languages/$LANG_TARGET ]; then
   echo -e "${txtblu}\nChecking $LANG_TARGET${txtrst}"
   rm -f $XML_TARGETS_ARRAYS $XML_TARGETS_STRINGS $XML_TARGETS_PLURALS
   find /home/translators.xiaomi.eu/scripts/languages/$LANG_TARGET -iname "arrays.xml" >> $XML_TARGETS_ARRAYS
   find /home/translators.xiaomi.eu/scripts/languages/$LANG_TARGET -iname "strings.xml" >> $XML_TARGETS_STRINGS
   find /home/translators.xiaomi.eu/scripts/languages/$LANG_TARGET -iname "plurals.xml" >> $XML_TARGETS_PLURALS
   sort $XML_TARGETS_ARRAYS > $XML_TARGETS_ARRAYS.new; mv $XML_TARGETS_ARRAYS.new $XML_TARGETS_ARRAYS
   sort $XML_TARGETS_STRINGS > $XML_TARGETS_STRINGS.new; mv $XML_TARGETS_STRINGS.new $XML_TARGETS_STRINGS
   sort $XML_TARGETS_PLURALS > $XML_TARGETS_PLURALS.new; mv $XML_TARGETS_PLURALS.new $XML_TARGETS_PLURALS
   debug_mode
   start_xml_check
fi
}

start_xml_check () {
cat $XML_TARGETS_ARRAYS | while read all_line; do
    xml_check "$all_line" arrays
done
cat $XML_TARGETS_STRINGS | while read all_line; do
    xml_check "$all_line" strings
done
cat $XML_TARGETS_PLURALS | while read all_line; do
    xml_check "$all_line" plurals
done
check_log
}

xml_check () {
XML=$1
XML_TARGET=$(echo $XML)
XML_TYPE=$2

if [ -e "$XML_TARGET" ]; then
     echo -e "</script><font color="#000000"><br>$XML_TARGET</font><script type="text/plain">" >> $XML_LOG
     xmllint --noout $XML_TARGET 2>> $XML_LOG
     if [ "$XML_TYPE" = "strings" ]; then
          rm -f $DOUBLE_RESULT
          cat $XML_TARGET | while read all_line; do grep "<string" | cut -d'>' -f1; done > $XML_TARGET_STRIPPED
          sort $XML_TARGET_STRIPPED | uniq --repeated >> $DOUBLE_RESULT
          cat $DOUBLE_RESULT | while read all_line; do grep -ne "$all_line" $XML_TARGET; done >> $XML_LOG
     fi
     grep -ne "+ * <s" $XML_TARGET >> $XML_LOG 
     LINE_NR=$(wc -l $XML_LOG | cut -d' ' -f1)
     if [ "$(sed -n "$LINE_NR"p $XML_LOG)" = "</script><font color="#000000"><br>$XML_TARGET</font><script type="text/plain">" ] || [ "$(sed -n "$LINE_NR"p $XML_LOG)" = "" ]; then 
          sed -i '$ d' $XML_LOG
     fi
fi
}

# Specific arguments
show_argument_help () { 
echo 
echo "MIUIAndroid.com language repo XML check"
echo 
echo "Usage: check.sh [option]"
echo 
echo " Options:"
echo " 		--help				This help"
echo "		--check_all [full] 		Check all languages"
echo "						full = log everything in one file (optional)"
echo "						Else it logs in seperate files (default)"
echo "		--check [your_language]	  	Check specified language"
echo "		--sync_all			Sync all languages"
echo "		--sync [your_language]		Sync specified language"
echo "						No option checks all languages, logged in one file"
echo 
exit 
}

if [ $# -gt 0 ]; then
     if [ $1 == "--help" ]; then
          show_argument_help
     elif [ $1 == "--check_all" ]; then
            clear_cache
            if [ "$2" = "full" ]; then
                  DEBUG_MODE=full
            else
                  DEBUG_MODE=lang
            fi
            check_xml_full
     elif [ $1 == "--check" ]; then
            clear_cache
            DEBUG_MODE=lang
            case "$2" in
                    arabic) init_xml_check "ar";; 
      brazilian-portuguese) init_xml_check "pt-rBR";;
                 bulgarian) init_xml_check "bg";;
                     czech) init_xml_check "cs";;
                    danish) init_xml_check "da";;
                     dutch) init_xml_check "nl";; 
                   english) init_xml_check "en";; 
                    french) init_xml_check "fr";;
                    german) init_xml_check "de";; 
                     greek) init_xml_check "el";; 
                 hungarian) init_xml_check "hu";; 
                indonesian) init_xml_check "in";; 
                   italian) init_xml_check "it";; 
                    korean) init_xml_check "ko";; 
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
                         *) echo "Language not supported"; exit;;
           esac
     elif [ $1 == "--sync_all" ]; then
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Arabic" "ar" "git@github.com:MIUI-Palestine/MIUIPalestine_V5_Arabic_XML.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Brazilian-Portuguese" "pt-rBR" "git@bitbucket.org:miuibrasil/ma-xml-5.0-portuguese-brazilian.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Bulgarian" "bg" "git@github.com:ingbrzy/MA-XML-5.0-BULGARIAN.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Czech" "cs" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-CZECH.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Danish" "da" "git@github.com:1982Strand/XML_MIUI-v5_Danish.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Dutch" "nl" "git@github.com:Redmaner/MA-XML-5.0-DUTCH.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "English" "en" "git@github.com:iBotPeaches/MIUIAndroid_XML_v5.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "French" "fr" "git@github.com:ingbrzy/ma-xml-5.0-FRENCH.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "German" "de" "git@github.com:Bitti09/ma-xml-5.0-german.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Greek" "el" "git@bitbucket.org:finner/ma-xml-5.0-greek.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Hungarian" "hu" "git@github.com:vagyula1/miui-v5-hungarian-translation-for-miuiandroid.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Indonesian" "in" "git@github.com:ingbrzy/MA-XML-5.0-INDONESIAN.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Italian" "it" "git@bitbucket.org:Mish/miui_v5_italy.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Korean" "ko" "git@github.com:nosoy1/ma-xml-5.0-korean.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Norwegian" "nb" "git@github.com:ingbrzy/MA-XML-5.0-NORWEGIAN.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Polish" "pl" "git@github.com:Acid-miuipolskapl/XML_MIUI-v5.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Romanian" "ro" "git@github.com:ingbrzy/MA-XML-5.0-ROMANIAN.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Russian" "ru" "git@github.com:KDGDev/miui-v5-russian-translation-for-miuiandroid.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Slovak" "sk" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-SLOVAK.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Spanish" "es" "git@github.com:ingbrzy/MA-XML-5.0-SPANISH.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Swedish" "sv" "git@github.com:ingbrzy/ma-xml-5.0-SWEDISH.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Thai" "th" "git@github.com:rcset/MIUIAndroid_XML_v5_TH.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Turkish" "tr" "git@github.com:ingbrzy/MA-XML-5.0-TURKISH.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Ukrainian" "uk" "git@github.com:KDGDev/miui-v5-ukrainian-translation-for-miuiandroid.git"
             /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Vietnamese" "vi" "git@github.com:HoangTuBot/MA-xml-v5-vietnam.git"
     elif [ $1 == "--sync" ]; then
            case "$2" in
                    arabic) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Arabic" "ar" "git@github.com:MIUI-Palestine/MIUIPalestine_V5_Arabic_XML.git";;
      brazilian-portuguese) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Brazilian-Portuguese" "pt-rBR" "git@bitbucket.org:miuibrasil/ma-xml-5.0-portuguese-brazilian.git";;
                 bulgarian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Bulgarian" "bg" "git@github.com:ingbrzy/MA-XML-5.0-BULGARIAN.git";;
                     czech) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Czech" "cs" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-CZECH.git";;
                    danish) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Danish" "da" "git@github.com:1982Strand/XML_MIUI-v5_Danish.git";;
                     dutch) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Dutch" "nl" "git@github.com:Redmaner/MA-XML-5.0-DUTCH.git";;
                   english) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "English" "en" "git@github.com:iBotPeaches/MIUIAndroid_XML_v5.git";;
                    french) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "French" "fr" "git@github.com:ingbrzy/ma-xml-5.0-FRENCH.git";;
                    german) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "German" "de" "git@github.com:Bitti09/ma-xml-5.0-german.git";;
                     greek) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Greek" "el" "git@bitbucket.org:finner/ma-xml-5.0-greek.git";;
                 hungarian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Hungarian" "hu" "git@github.com:vagyula1/miui-v5-hungarian-translation-for-miuiandroid.git";;
                indonesian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Indonesian" "in" "git@github.com:ingbrzy/MA-XML-5.0-INDONESIAN.git";;
                   italian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Italian" "it" "git@bitbucket.org:Mish/miui_v5_italy.git";;
                    korean) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Korean" "ko" "git@github.com:nosoy1/ma-xml-5.0-korean.git";;
                 norwegian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Norwegian" "nb" "git@github.com:ingbrzy/MA-XML-5.0-NORWEGIAN.git";;
                    polish) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Polish" "pl" "git@github.com:Acid-miuipolskapl/XML_MIUI-v5.git";;
                  romanian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Romanian" "ro" "git@github.com:ingbrzy/MA-XML-5.0-ROMANIAN.git";;
                   russian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Russian" "ru" "git@github.com:KDGDev/miui-v5-russian-translation-for-miuiandroid.git";;
                    slovak) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Slovak" "sk" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-SLOVAK.git";;
                   spanish) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Spanish" "es" "git@github.com:ingbrzy/MA-XML-5.0-SPANISH.git";;
                   swedish) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Swedish" "sv" "git@github.com:ingbrzy/ma-xml-5.0-SWEDISH.git";;
                      thai) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Thai" "th" "git@github.com:rcset/MIUIAndroid_XML_v5_TH.git";;
                   turkish) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Turkish" "tr" "git@github.com:ingbrzy/MA-XML-5.0-TURKISH.git";;
                 ukrainian) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Ukrainian" "uk" "git@github.com:KDGDev/miui-v5-ukrainian-translation-for-miuiandroid.git";;
                vietnamese) /home/translators.xiaomi.eu/scripts/languages/sync_lang.sh "Vietnamese" "vi" "git@github.com:HoangTuBot/MA-xml-v5-vietnam.git";;
                         *) echo "Language not supported"; exit;;
           esac
     else
            show_argument_help
     fi
else
     clear_cache
     DEBUG_MODE=full
     check_xml_full
fi

