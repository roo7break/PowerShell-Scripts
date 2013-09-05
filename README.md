PowerShell-Scripts
==================
The following PowerShell scripts have been conjured up during my research into the topic. I cannot guarantee their stability, but rest assured I wont publish them unless they work.

For more information about the scripts and their usage check out my site www.roo7break.co.uk

### Table of Contents
- [Auto-Gpppassword.ps1](#autogpp)
- [Firewall Egress testing](#egress)

<a name="autogpp"/>
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

<a name="egress"/>
#### Firewall Egress testing

**Supported Protocols**

 - TCP
 - UDP (TBA)
 - HTTP/S (TBA)

##### FireBuster.ps1

**Version:** v1.0

**Info**
Firebuster is a PowerShell script that will try and connect to the listening server of your choice through the port range you have provided.

**Usage**

> .\FireBuster.ps1 <ipaddress-of-listening-server> <port-range>

Example:

> .\FireBuster.ps1 192.168.193.130 3000-3010

##### FireListener.ps1

**Version:** v0.1

**Info**

Since, I wrote FireBuster in PowerShell it would only make sense to try and implement a listening server using PowerShell. To be honest, I was gonna just rely on Dave’s egress_listening script. But after having a conversation with Nikhil Mittal (@nikhil_mitt) he suggested I write the listener in PowerShell too.

Unlike FireBuster, the listening wasn’t easy as PowerShell isnt that flexible with multi threading (or to put it in another way, I found very hard Open-mouthed smile). So, I would say FireListener is not stable, but works.

I would also urge you not to run more than 10 ports at the same time. For some reason I am not aware of, the memory consumption shoots up with each background process (each port is a separate process).

**WARNING:** FireListener.ps1 has some problems (see below). I wrote FireListener as a proof-of-concept. It did introduce me to multi-threading in PowerShell.

**Usage**

> .\FireListener.ps1 <port-range-to-listen-on>

By default FireListener will bind to 0.0.0.0.

Example

> .\FireListener.ps1 3000-3010.

Issues that need to be resolved

 - Once client data is received over a port, the open socket closes.
 - Start-Job information that is being displayed needs to be hidden
 - Memory consumption to be reduced. 

I am also including a Python based listener that you can run on your listening server.

##### pyfirelistener.py
**Version:** v1.0

**Info**

PyFireListener is a python implementation of FireListener for a PowerShell-less environment. It also provides a stabler option to FireListener.

**Usage**

> ./pyfirelistener.py 4000 4100

**Credits**

Kudos to the following people who inspired me to get into PowerShell and provided information which helped me during scripting:
 
- Dave Rel1k’s egressbuster (which was the inspiration for my script)
 - Link: https://www.trustedsec.com/february-2012/new-tool-release-egress-buster-find-outbound-ports/
- Nikhil Mittal (@nikhil_mitt) for providing valuable inputs on PowerShell
- Thomas Forbes (tomforb.es) for helping me with some code snippets
- TheSurlyAdmin
 - http://thesurlyadmin.com/2013/02/11/multithreading-powershell-scripts/

**Other resources**

- http://chris-nullpayload.rhcloud.com/2012/07/simple-tcp-listener/
- http://www.skipdaflip.nl/powershell/communicate-through-tcp-with-powershell/