#!/bin/bash
# Copyright (c) 2013 - 2018, Redmaner
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license
# The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/

do_xml_fix() {
	if [ -e $CACHE/$LANG_TARGET.cached/parser.ok ]; then
		$MAIN_DIR/mixml format --dir $LANG_DIR/$LANG_TARGET --filter --config $LANG_FILTER
		echo "Auto fixed" > $CACHE/$LANG_TARGET.cached/$LANG_TARGET.fixed
	fi
}

check_for_auto_fix () {
	find $CACHE -iname "*.fixed" | while read fixed_lang; do
		CACHED_FIX=$(dirname $fixed_lang)
		init_lang $(cat $LANGS_ALL | grep ''$(cat $CACHED_FIX/lang_version)' '$(cat $CACHED_FIX/lang_name)'');
		push_to_repository "Auto fixes by translators.xiaomi.eu"
	done
}
