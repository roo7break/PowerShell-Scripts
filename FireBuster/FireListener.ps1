<#
.Synopsis

FireListener is a PowerShell script that supports FireBuster in egress testing. FireListener will allow you to
host a listening server to which FireBuster can send packets to. 

Author: Nikhil Sreekunar (@roo7break)
License: GNU GPL v2
Version: v0.1

.Description
FireListener is a PowerShell script that supports FireBuster in egress testing. FireListener will allow you to
host a listening server to which FireBuster can send packets to. 

.Usage
.\FireListerner <port range>

.Example
.\FireListener.ps1 1000-1020

.Links
http://roo7break.co.uk
https://www.trustedsec.com/february-2012/new-tool-release-egress-buster-find-outbound-ports/

.Issues
- Hide start-job information
- Reduce memory consumption for more than 10 background processes
- Keep sockets open even after data is received once.
#>

Param( [Parameter(Mandatory = $False)] [String] $portrange = "5000-5002")

function FireListener{

	$socketblock = {
			param($port = $args[1])
			try
			{
				$EndPoint = New-Object System.Net.IPEndPoint([ipaddress]::any, $port)
				$ListenSocket = New-Object System.Net.Sockets.TCPListener $EndPoint
				$ListenSocket.Start()
				
				$RecData = $ListenSocket.AcceptTCPClient()
				$Databytes = New-Object System.Byte[] 1024
				$Stream = $RecData.GetStream()
				while (($i = $Stream.Read($Databytes,0,$Databytes.Length)) -ne 0)
				{
					# I am not using the client data. But if you want to just remove the comments and have a go.
					#$EncodedText = New-Object System.Text.ASCIIEncoding
					#$clientdata = $EncodedText.GetString($Databytes,0,$i) 
					$clientip = $RecData.Client.RemoteEndPoint
					Write-Output "$($clientip.Address.ToString()) connected through port $($clientip.Port.ToString())"
				}
				$Stream.Close()
				$ListenSocket.Stop()
			} catch
				{ Write-Error $Error[0]	}
	}
	
	[int] $lowport = $portrange.split("-")[0]
    [int] $highport = $portrange.split("-")[1]
	
    $ErrorActionPreference = 'SilentlyContinue'
	[int] $ports = 0
	
    get-job | remove-job
    
	for($ports=$lowport; $ports -le $highport; $ports++)
		{
			start-job -ScriptBlock $socketblock -ArgumentList $ports | out-null
		}
	do
	{
		foreach($Job in (Get-Job))
		{
			Receive-Job $Job
		}
	} while(1)
}
FireListener