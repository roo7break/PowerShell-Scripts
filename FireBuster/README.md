Firewall Egress testing
==========================

**Supported Protocols**

 - TCP
 - UDP (TBA)
 - HTTP/S (TBA)

##FireBuster.ps1

**Version:** v1.0

**Info**
Firebuster is a PowerShell script that will try and connect to the listening server of your choice through the port range you have provided.

**Usage**

> .\FireBuster.ps1 <ipaddress-of-listening-server> <port-range>

Example:

> .\FireBuster.ps1 192.168.193.130 3000-3010


##FireListener.ps1


**Version:** v0.2

**Changelog:**

***v0.2*** - Improvements

Thanks to Nikhil Mittal who helped to resolve some stability issues that the previous version had.

***v0.1*** - First release

**Info**

Since, I wrote FireBuster in PowerShell it would only make sense to try and implement a listening server using PowerShell. To be honest, I was gonna just rely on Dave’s egress_listening script. But after having a conversation with Nikhil Mittal (@nikhil_mitt) he suggested I write the listener in PowerShell too.

Unlike FireBuster, the listening wasn’t easy as PowerShell isnt that flexible with multi threading (or to put it in another way, I found very hard Open-mouthed smile). So, I would say FireListener is not stable, but works.

I would also urge you not to run more than 10 ports at the same time. For some reason I am not aware of, the memory consumption shoots up with each background process (each port is a separate process).

**Usage**

> .\FireListener.ps1 <port-range-to-listen-on>

By default FireListener will bind to 0.0.0.0.

Example

> .\FireListener.ps1 3000-3010.

I am also including a Python based listener that you can run on your listening server.

##pyfirelistener.py
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