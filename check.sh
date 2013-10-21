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

LANG_TARGETS=.cache/language.targets
XML_TARGETS=.cache/xml.targets
source options.cfg

rm -rf .cache
mkdir -p .cache
mkdir -p logs

debug_mode () {
if [ $DEBUG_MODE = "full" ]; then
     XML_LOG=.cache/XML_CHECK_FULL.log
else
     XML_LOG=.cache/XML_$LANG_NAME.log
fi
echo -e "\n########################\n$LANG_NAME\n########################" >> $XML_LOG
exec 2>> $XML_LOG
}

check_log () {
if [ $DEBUG_MODE = "full" ]; then
     cp $XML_LOG logs/XML_CHECK_FULL.log
     echo -e "${txtgrn}$LANG_NAME checked, log at logs/XML_CHECK_FULL.log${txtrst}"
else
     cp $XML_LOG logs/XML_$LANG_NAME.log
     echo -e "${txtgrn}$LANG_NAME checked, log at logs/XML_$LANG_NAME.log${txtrst}"
fi
}

check_xml_full () {
ls languages > $LANG_TARGETS
cat $LANG_TARGETS | while read all_line; do
    init_xml_check "$all_line" 
done
}

init_xml_check () {
LANG=$1
LANG_TARGET=$(echo $LANG)

if [ -d languages/$LANG_TARGET ]; then
   echo -e "${txtblu}\nChecking $LANG_NAME${txtrst}"
   rm -f $XML_TARGETS
   find languages/$LANG_TARGET -iname "arrays.xml" >> $XML_TARGETS
   find languages/$LANG_TARGET -iname "strings.xml" >> $XML_TARGETS
   find languages/$LANG_TARGET -iname "plurals.xml" >> $XML_TARGETS 
   sort $XML_TARGETS > $XML_TARGETS.new; mv $XML_TARGETS.new $XML_TARGETS
   debug_mode
   start_xml_check
fi
}

start_xml_check () {
cat $XML_TARGETS | while read all_line; do
    xml_check "$all_line" 
done
check_log
}

xml_check () {
XML=$1
XML_TARGET=$(echo $XML)

if [ -e $XML_TARGET ]; then
     echo -e "\n##$XML_TARGET\n##########" >> $XML_LOG
     xmllint --noout $XML_TARGET >> $XML_LOG
     uniq -d $XML_TARGET  >> $XML_LOG
     grep -ne "+ * <" $XML_TARGET >> $XML_LOG
fi
}

# Specific arguments
show_argument_help () { 
echo 
echo "MIUIAndroid.com XML language check"
echo 
echo "Usage: check.sh [option]"
echo 
echo " Options:"
echo " 		--help				This help"
echo "		--check_all			Check all languages (default)"
echo "		--check [your_language]	  	Check specified language"
echo "		--debug_full			Debug all languages in one log"
echo "		--debug_lang			Debug languages in seperate logs (default)"
echo "		--sync_all			Sync all languages"
echo "		--sync [your_language]		Sync specified language"
echo 
exit 
}

if [ $# -gt 0 ]; then
     if [ $1 == "--help" ]; then
          show_argument_help
     elif [ $1 == "--check_all" ]; then
            check_xml_full
     elif [ $1 == "--check" ]; then
            LANG_NAME=$2
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
             languages/sync_lang.sh "Arabic" "ar" "git@github.com:MIUI-Palestine/MIUIPalestine_V5_Arabic_XML.git"
             languages/sync_lang.sh "Brazilian-Portuguese" "pt-rBR" "git@bitbucket.org:miuibrasil/ma-xml-5.0-portuguese-brazilian.git"
             languages/sync_lang.sh "Bulgarian" "bg" "git@github.com:ingbrzy/MA-XML-5.0-BULGARIAN.git"
             languages/sync_lang.sh "Czech" "cs" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-CZECH.git"
             languages/sync_lang.sh "Danish" "da" "git@github.com:1982Strand/XML_MIUI-v5_Danish.git"
             languages/sync_lang.sh "Dutch" "nl" "git@github.com:Redmaner/MA-XML-5.0-DUTCH.git"
             languages/sync_lang.sh "English" "en" "git@github.com:iBotPeaches/MIUIAndroid_XML_v5.git"
             languages/sync_lang.sh "French" "fr" "git@github.com:ingbrzy/ma-xml-5.0-FRENCH.git"
             languages/sync_lang.sh "German" "de" "git@github.com:Bitti09/ma-xml-5.0-german.git"
             languages/sync_lang.sh "Greek" "el" "git@bitbucket.org:finner/ma-xml-5.0-greek.git"
             languages/sync_lang.sh "Hungarian" "hu" "git@github.com:vagyula1/miui-v5-hungarian-translation-for-miuiandroid.git"
             languages/sync_lang.sh "Indonesian" "in" "git@github.com:ingbrzy/MA-XML-5.0-INDONESIAN.git"
             languages/sync_lang.sh "Italian" "it" "git@bitbucket.org:Mish/miui_v5_italy.git"
             languages/sync_lang.sh "Korean" "ko" "git@github.com:nosoy1/ma-xml-5.0-korean.git"
             languages/sync_lang.sh "Norwegian" "nb" "git@github.com:ingbrzy/MA-XML-5.0-NORWEGIAN.git"
             languages/sync_lang.sh "Polish" "pl" "git@github.com:Acid-miuipolskapl/XML_MIUI-v5.git"
             languages/sync_lang.sh "Romanian" "ro" "git@github.com:ingbrzy/MA-XML-5.0-ROMANIAN.git"
             languages/sync_lang.sh "Russian" "ru" "git@github.com:KDGDev/miui-v5-russian-translation-for-miuiandroid.git"
             languages/sync_lang.sh "Slovak" "sk" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-SLOVAK.git"
             languages/sync_lang.sh "Spanish" "es" "git@github.com:ingbrzy/MA-XML-5.0-SPANISH.git"
             languages/sync_lang.sh "Swedish" "sv" "git@github.com:ingbrzy/ma-xml-5.0-SWEDISH.git"
             languages/sync_lang.sh "Thai" "th" "git@github.com:rcset/MIUIAndroid_XML_v5_TH.git"
             languages/sync_lang.sh "Turkish" "tr" "git@github.com:ingbrzy/MA-XML-5.0-TURKISH.git"
             languages/sync_lang.sh "Ukrainian" "uk" "git@github.com:KDGDev/miui-v5-ukrainian-translation-for-miuiandroid.git"
             languages/sync_lang.sh "Vietnamese" "vi" "git@github.com:HoangTuBot/MA-xml-v5-vietnam.git"
     elif [ $1 == "--sync" ]; then
            LANG_NAME=$2
            case "$2" in
                    arabic) languages/sync_lang.sh "Arabic" "ar" "git@github.com:MIUI-Palestine/MIUIPalestine_V5_Arabic_XML.git";;
      brazilian-portuguese) languages/sync_lang.sh "Brazilian-Portuguese" "pt-rBR" "git@bitbucket.org:miuibrasil/ma-xml-5.0-portuguese-brazilian.git";;
                 bulgarian) languages/sync_lang.sh "Bulgarian" "bg" "git@github.com:ingbrzy/MA-XML-5.0-BULGARIAN.git";;
                     czech) languages/sync_lang.sh "Czech" "cs" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-CZECH.git";;
                    danish) languages/sync_lang.sh "Danish" "da" "git@github.com:1982Strand/XML_MIUI-v5_Danish.git";;
                     dutch) languages/sync_lang.sh "Dutch" "nl" "git@github.com:Redmaner/MA-XML-5.0-DUTCH.git";;
                   english) languages/sync_lang.sh "English" "en" "git@github.com:iBotPeaches/MIUIAndroid_XML_v5.git";;
                    french) languages/sync_lang.sh "French" "fr" "git@github.com:ingbrzy/ma-xml-5.0-FRENCH.git";;
                    german) languages/sync_lang.sh "German" "de" "git@github.com:Bitti09/ma-xml-5.0-german.git";;
                     greek) languages/sync_lang.sh "Greek" "el" "git@bitbucket.org:finner/ma-xml-5.0-greek.git";;
                 hungarian) languages/sync_lang.sh "Hungarian" "hu" "git@github.com:vagyula1/miui-v5-hungarian-translation-for-miuiandroid.git";;
                indonesian) languages/sync_lang.sh "Indonesian" "in" "git@github.com:ingbrzy/MA-XML-5.0-INDONESIAN.git";;
                   italian) languages/sync_lang.sh "Italian" "it" "git@bitbucket.org:Mish/miui_v5_italy.git";;
                    korean) languages/sync_lang.sh "Korean" "ko" "git@github.com:nosoy1/ma-xml-5.0-korean.git";;
                 norwegian) languages/sync_lang.sh "Norwegian" "nb" "git@github.com:ingbrzy/MA-XML-5.0-NORWEGIAN.git";;
                    polish) languages/sync_lang.sh "Polish" "pl" "git@github.com:Acid-miuipolskapl/XML_MIUI-v5.git";;
                  romanian) languages/sync_lang.sh "Romanian" "ro" "git@github.com:ingbrzy/MA-XML-5.0-ROMANIAN.git";;
                   russian) languages/sync_lang.sh "Russian" "ru" "git@github.com:KDGDev/miui-v5-russian-translation-for-miuiandroid.git";;
                    slovak) languages/sync_lang.sh "Slovak" "sk" "git@github.com:MIUICzech-Slovak/MA-XML-5.0-SLOVAK.git";;
                   spanish) languages/sync_lang.sh "Spanish" "es" "git@github.com:ingbrzy/MA-XML-5.0-SPANISH.git";;
                   swedish) languages/sync_lang.sh "Swedish" "sv" "git@github.com:ingbrzy/ma-xml-5.0-SWEDISH.git";;
                      thai) languages/sync_lang.sh "Thai" "th" "git@github.com:rcset/MIUIAndroid_XML_v5_TH.git";;
                   turkish) languages/sync_lang.sh "Turkish" "tr" "git@github.com:ingbrzy/MA-XML-5.0-TURKISH.git";;
                 ukrainian) languages/sync_lang.sh "Ukrainian" "uk" "git@github.com:KDGDev/miui-v5-ukrainian-translation-for-miuiandroid.git";;
                vietnamese) languages/sync_lang.sh "Vietnamese" "vi" "git@github.com:HoangTuBot/MA-xml-v5-vietnam.git";;
                         *) echo "Language not supported"; exit;;
           esac
     elif [ $1 == "--debug_full" ]; then
            sed -i "/DEBUG_MODE=*/ d" options.cfg
            echo "DEBUG_MODE=full" >> options.cfg
     elif [ $1 == "--debug_lang" ]; then
            sed -i "/DEBUG_MODE=*/ d" options.cfg
            echo "DEBUG_MODE=lang" >> options.cfg
     else
            show_argument_help
     fi
else
     check_xml_full
fi

