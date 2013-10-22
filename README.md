By Redmaner - MIUIAndroid.com 

What is this for?
-------------------------------------------------------------------------------------
This will check a MIUIAndroid.com language repo for XML errors.<br>
It checks the xmls for three things:
- Common XML errors, e.g. non closing tags <>
- Double tags
- A "+" before a tag

What do I need to run this?
-------------------------------------------------------------------------------------
- Linux or Mac OSX (windows not supported, could be working on cygwin)
- Packages: grep, libxml (xmllint), uniq, sort

Options
-------------------------------------------------------------------------------------
<code>./check.sh --help</code>
Note: Sync repo's first before starting a check!

