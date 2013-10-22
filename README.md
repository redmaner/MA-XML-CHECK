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
<code>MIUIAndroid.com language repo XML check<br>
<br>
Usage: check.sh [option]<br>
<br>
Options:<br>
 		--help				This help<br>
		--check_all [full] 		Check all languages<br>
						full = log everything in one file (optional)<br>
						Else it logs in seperate files (default)<br>
		--check [your_language]	  	Check specified language<br>
		--sync_all			Sync all languages<br>
		--sync [your_language]		Sync specified language<br>
						No option checks all languages, logged in one file<br></code>
Note: Sync repo's first before starting a check!<br>

