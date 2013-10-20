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

rm -rf .cache
mkdir -p .cache
mkdir -p logs

debug_mode () {
if [ $(cat options.cfg | grep "debug=*" | cut -d"=" -f2) = "full" ]; then
     XML_LOG=.cache/XML_CHECK_FULL.log
     exec 2>> $XML_LOG
     echo -e "\n########################\n$LANG_TARGET\n########################" >> $XML_LOG
else
     XML_LOG=.cache/XML_$LANG_TARGET.log
     exec 2>> $XML_LOG
fi
}

check_log () {
if [ $(cat options.cfg | grep "debug=*" | cut -d"=" -f2) = "full" ]; then
     cp $XML_LOG logs/XML_CHECK_FULL.log
     echo -e "${txtgrn}$LANG_TARGET checked, log at logs/XML_CHECK_FULL.log${txtrst}"
else
     cp $XML_LOG logs/XML_$LANG_TARGET.log
     echo -e "${txtgrn}$LANG_TARGET checked, log at logs/XML_$LANG_TARGET.log${txtrst}"
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
   echo -e "${txtblu}\nChecking $LANG_TARGET${txtrst}"
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
     uniq -cd $XML_TARGET >> $XML_LOG
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
             languages/sync_lang.sh "Arabic" "ar" "https://github.com/MIUI-Palestine/MIUIPalestine_V5_Arabic_XML"
             languages/sync_lang.sh "Brazilian-Portuguese" "pt-rBR" "https://bitbucket.org/miuibrasil/ma-xml-5.0-portuguese-brazilian"
             languages/sync_lang.sh "Bulgarian" "bg" "https://github.com/ingbrzy/MA-XML-5.0-BULGARIAN"
             languages/sync_lang.sh "Czech" "cs" "https://github.com/MIUICzech-Slovak/MA-XML-5.0-CZECH"
             languages/sync_lang.sh "Danish" "da" "https://github.com/1982Strand/XML_MIUI-v5_Danish"
             languages/sync_lang.sh "Dutch" "nl" "https://github.com/Redmaner/MA-XML-5.0-DUTCH"
             languages/sync_lang.sh "English" "en" "https://github.com/iBotPeaches/MIUIAndroid_XML_v5"
             languages/sync_lang.sh "French" "fr" "https://github.com/ingbrzy/ma-xml-5.0-FRENCH"
             languages/sync_lang.sh "German" "de" "https://github.com/Bitti09/ma-xml-5.0-german"
             languages/sync_lang.sh "Greek" "el" "https://bitbucket.org/finner/ma-xml-5.0-greek"
             languages/sync_lang.sh "Hungarian" "hu" "https://github.com/vagyula1/miui-v5-hungarian-translation-for-miuiandroid"
             languages/sync_lang.sh "Indonesian" "in" "https://github.com/ingbrzy/MA-XML-5.0-INDONESIAN"
             languages/sync_lang.sh "Italian" "it" "https://bitbucket.org/Mish/miui_v5_italy"
             languages/sync_lang.sh "Korean" "ko" "https://github.com/nosoy1/ma-xml-5.0-korean"
             languages/sync_lang.sh "Norwegian" "nb" "https://github.com/ingbrzy/MA-XML-5.0-NORWEGIAN"
             languages/sync_lang.sh "Polish" "pl" "https://github.com/Acid-miuipolskapl/XML_MIUI-v5"
             languages/sync_lang.sh "Romanian" "ro" "https://github.com/ingbrzy/MA-XML-5.0-ROMANIA"
             languages/sync_lang.sh "Russian" "ru" "https://github.com/KDGDev/miui-v5-russian-translation-for-miuiandroid"
             languages/sync_lang.sh "Slovak" "sk" "https://github.com/MIUICzech-Slovak/MA-XML-5.0-SLOVAK"
             languages/sync_lang.sh "Spanish" "es" "https://github.com/ingbrzy/MA-XML-5.0-SPANISH"
             languages/sync_lang.sh "Swedish" "sv" "https://github.com/ingbrzy/ma-xml-5.0-SWEDISH"
             languages/sync_lang.sh "Thai" "th" "https://github.com/rcset/MIUIAndroid_XML_v5_TH"
             languages/sync_lang.sh "Turkish" "tr" "https://github.com/ingbrzy/MA-XML-5.0-TURKISH"
             languages/sync_lang.sh "Ukrainian" "uk" "https://github.com/KDGDev/miui-v5-ukrainian-translation-for-miuiandroid"
             languages/sync_lang.sh "Vietnamese" "vi" "https://github.com/HoangTuBot/MA-xml-v5-vietnam"
     elif [ $1 == "--sync_lang" ]; then
            case "$2" in
                    arabic) languages/sync_lang.sh "Arabic" "ar" "https://github.com/MIUI-Palestine/MIUIPalestine_V5_Arabic_XML";;
      brazilian-portuguese) languages/sync_lang.sh "Brazilian-Portuguese" "pt-rBR" "https://bitbucket.org/miuibrasil/ma-xml-5.0-portuguese-brazilian";;
                 bulgarian) languages/sync_lang.sh "Bulgarian" "bg" "https://github.com/ingbrzy/MA-XML-5.0-BULGARIAN";;
                     czech) languages/sync_lang.sh "Czech" "cs" "https://github.com/MIUICzech-Slovak/MA-XML-5.0-CZECH";;
                    danish) languages/sync_lang.sh "Danish" "da" "https://github.com/1982Strand/XML_MIUI-v5_Danish";;
                     dutch) languages/sync_lang.sh "Dutch" "nl" "https://github.com/Redmaner/MA-XML-5.0-DUTCH";;
                   english) languages/sync_lang.sh "English" "en" "https://github.com/iBotPeaches/MIUIAndroid_XML_v5";;
                    french) languages/sync_lang.sh "French" "fr" "https://github.com/ingbrzy/ma-xml-5.0-FRENCH";;
                    german) languages/sync_lang.sh "German" "de" "https://github.com/Bitti09/ma-xml-5.0-german";;
                     greek) languages/sync_lang.sh "Greek" "el" "https://bitbucket.org/finner/ma-xml-5.0-greek";;
                 hungarian) languages/sync_lang.sh "Hungarian" "hu" "https://github.com/vagyula1/miui-v5-hungarian-translation-for-miuiandroid";;
                indonesian) languages/sync_lang.sh "Indonesian" "in" "https://github.com/ingbrzy/MA-XML-5.0-INDONESIAN";;
                   italian) languages/sync_lang.sh "Italian" "it" "https://bitbucket.org/Mish/miui_v5_italy";;
                    korean) languages/sync_lang.sh "Korean" "ko" "https://github.com/nosoy1/ma-xml-5.0-korean";;
                 norwegian) languages/sync_lang.sh "Norwegian" "nb" "https://github.com/ingbrzy/MA-XML-5.0-NORWEGIAN";;
                    polish) languages/sync_lang.sh "Polish" "pl" "https://github.com/Acid-miuipolskapl/XML_MIUI-v5";;
                  romanian) languages/sync_lang.sh "Romanian" "ro" "https://github.com/ingbrzy/MA-XML-5.0-ROMANIA";;
                   russian) languages/sync_lang.sh "Russian" "ru" "https://github.com/KDGDev/miui-v5-russian-translation-for-miuiandroid";;
                    slovak) languages/sync_lang.sh "Slovak" "sk" "https://github.com/MIUICzech-Slovak/MA-XML-5.0-SLOVAK";;
                   spanish) languages/sync_lang.sh "Spanish" "es" "https://github.com/ingbrzy/MA-XML-5.0-SPANISH";;
                   swedish) languages/sync_lang.sh "Swedish" "sv" "https://github.com/ingbrzy/ma-xml-5.0-SWEDISH";;
                      thai) languages/sync_lang.sh "Thai" "th" "https://github.com/rcset/MIUIAndroid_XML_v5_TH";;
                   turkish) languages/sync_lang.sh "Turkish" "tr" "https://github.com/ingbrzy/MA-XML-5.0-TURKISH";;
                 ukrainian) languages/sync_lang.sh "Ukrainian" "uk" "https://github.com/KDGDev/miui-v5-ukrainian-translation-for-miuiandroid";;
                vietnamese) languages/sync_lang.sh "Vietnamese" "vi" "https://github.com/HoangTuBot/MA-xml-v5-vietnam";;
                         *) echo "Language not supported"; exit;;
           esac
     elif [ $1 == "--debug_full" ]; then
            sed -i "/debug=*/ d" options.cfg
            echo "debug=full" >> options.cfg
     elif [ $1 == "--debug_lang" ]; then
            sed -i "/debug=*/ d" options.cfg
            echo "debug=lang" >> options.cfg
     else
            show_argument_help
     fi
else
     check_xml_full
fi

