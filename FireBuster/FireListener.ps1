<#
.Synopsis

FireListener is a PowerShell script that supports FireBuster in egress testing. FireListener will allow you to
host a listening server to which FireBuster can send packets to. 

Author(s): Nikhil Sreekumar (@roo7break) & Nikhil Mittal (@nikhil_mitt)
License: GNU GPL v2
Version: v1.0

.Description
FireListener is a PowerShell script that supports FireBuster in egress testing. FireListener will allow you to
host a listening server to which FireBuster can send packets to. 

.Usage
.\FireListerner <port range>

.Example
.\FireListener.ps1 1000-1020

.Links
http://roo7break.co.uk
http://labofapenetrationtester.blogspot.in
https://www.trustedsec.com/february-2012/new-tool-release-egress-buster-find-outbound-ports/
http://poshcode.org/542

.Changelog:
1.0: Stable version released. Thanks to Nikhil Mittal (@nikhil_mitt) for providing stability fixes.

0.2:
- Ctrl+C implemented and ports remain open after first data is received.
- Thanks to Nikhil Mittal (@nikhil_mitt) for his valuable inputs.

0.1 - first release
#>

Param( [Parameter(Mandatory = $False)] [String] $portrange = "100-1000")

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
					while (($i = $Stream.Read($Databytes,0,$Databytes.Length)) -ne 0 )
					{
						$EncodedText = New-Object System.Text.ASCIIEncoding
						$clientdata = $EncodedText.GetString($Databytes,0,$i)
						$clientip = $RecData.Client.RemoteEndPoint
						Write-Output "$($clientip.Address.ToString()) connected through port $clientdata"
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
	   
		Get-Job | Remove-Job

		for($ports=$lowport; $ports -le $highport; $ports++)
			{
				$job = start-job -ScriptBlock $socketblock -ArgumentList $ports
				Write-Host "Listener on $ports is"$job.State
			}
		[console]::TreatControlCAsInput = $true
		while ($true)
		{
			# code from http://poshcode.org/542 to capture Ctrl+C
			# start code snip
			if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
			{
				Write-Host "Exiting and shutting down the jobs. No turning back...." -Background DarkRed
				Sleep 2
				Get-Job | Stop-Job 
				Get-Job | Remove-Job
				break;
			}
			# end code snip
			$jobs = Get-Job
			foreach ($job1 in $jobs)
			{ 
				Start-Sleep -Seconds 4
				
					if ($job1.state -eq "Completed")
					{
						$port = $job1.Name
						start-job -ScriptBlock $socketblock -ArgumentList $port -Name $port
						Get-Job | Remove-Job
					}
			}
		}
}
FireListener