Copyright (c) 2013 - 2015, Redmaner<br>
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license<br>
The license can be found at http://creativecommons.org/licenses/by-nc-sa/4.0/<br>

This code is live on:<br>
<a href="http://translators.xiaomi.eu">translators.xiaomi.eu</a><br>
This website can be used to dermine the errors below, you also could use this code to do it on your local machine.

What is this for?
-------------------------------------------------------------------------------------
This will check a MIUIAndroid.com language repo for XML errors.<br>
It checks the xmls for three things:
- Common XML errors, e.g. non closing tags <>, UTF8 encoding issues etc.
- Doubles
- A "+" before a tag
- Apostrophe syntax errors
- Untranslateable strings
- Array items 

What do I need to run this?
-------------------------------------------------------------------------------------
- Linux or Mac OSX 
- Packages: libxml (xmllint), uniq, sort

Options
-------------------------------------------------------------------------------------
<i>./check.sh --help</i><br>
Note: Sync repo's first before starting a check!

