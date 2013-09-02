PowerShell-Scripts
==================
The following PowerShell scripts have been conjured up during my research into the topic. I cannot guarantee their stability, but rest assured I wont publish them unless they work.

For more information about the scripts and their usage check out my site www.roo7break.co.uk

#### Auto-Gpppassword.ps1
**Version:** v1.0

**Info**

Auto-gpppassword will enumerate all the domains to which the current user is a member of as well as all domains accessible within the network before trying to extract and decrypt the encrypted local admin passwords. This script is based on Get-GPPPassword.ps1 by Chris Cambell (@obscuresec) and extends capability for enumerating additional Active Directory servers visible to the current users and testing network accessibility to the enumerated servers.

It also scans for Printers.xml and Drives.xml files for CPassword field (this is not supported within Get-GPPPassword). Checked on 02 Sept 2013 within the [Github repo](https://github.com/mattifestation/PowerSploit/blob/master/Exfiltration/Get-GPPPassword.ps1).

**Usage**

Default is to enumerate domains to which current user is a member of

> .\auto-gpppassword

To enumerate all domains accessible from the network

> .\auto-gpppassword -enumall:$true

By default the script will check for network access to the server. This might require admin access to the system (for packet crafting).

> .\auto-gpppassword -nochk:$true

**Credits**

Auto-Gpppassword.ps1 is based on Get-GPPPassword by Chris Cambell (@obscuresec) which retrieves the encrypted password for local admin accounts pushed through Group Policy Preferences and then decrypts it. Check out [Chris's blog](http://www.obscuresecurity.blogspot.com/2012/05/gpp-password-retrieval-with-powershell.html).

**Links**

Below are links to useful references regarding GPP exploitation that helped me during research.

* http://esec-pentest.sogeti.com/exploiting-windows-2008-group-policy-preferences
* http://www.obscuresecurity.blogspot.com/2012/05/gpp-password-retrieval-with-powershell.html
* http://rewtdance.blogspot.co.uk/2012/06/exploiting-windows-2008-group-policy.html
* http://dev.metasploit.com/redmine/projects/framework/repository/entry/modules/post/windows/gather/credentials/gpp.rb