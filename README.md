Copyright (c) 2013 - 2016, Redmaner<br>
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license<br>
The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/<br>

This code is live on: <a href="http://translators.xiaomi.eu">translators.xiaomi.eu</a><br>
This website can be used to dermine the errors below, you also could use this code to do it on your local machine.

What is this for?
-------------------------------------------------------------------------------------
This will check a xiaomi.eu language repositories for XML errors.<br>
The script will check strings.xml, arrays.xml and plurals.xml for the following possible errors:<br>
- XML syntax/parser errors (non closing < >, UTF-8 encoding etc.)
- Double strings 
- Apostrophe syntax errors 
- Untranslateable strings (predefined and automatically)
- Wrong values folder
- Wrong variable formatting 
- + outside of XML elements

What do I need to run this?
-------------------------------------------------------------------------------------
- Linux or Mac OSX 
- Packages: libxml (xmllint), uniq, sort

Options
-------------------------------------------------------------------------------------
<i>./check.sh --help</i><br>
Note: Sync repo's first before starting a check!

