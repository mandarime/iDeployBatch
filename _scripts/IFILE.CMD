@ECHO off
mode con cols=60 lines=15
TITLE ifile
color 8F
	Echo ecriture du fichier
	echo ---------------------------- ANCIEN POSTE --------------------------------------> %cd:~0,3%Migration\%computername%\%computername%.txt
	echo DATE .............................: %DATE% %TIME% >> %cd:~0,3%Migration\%computername%\%computername%.txt
	echo NOM MACHINE ......................: %COMPUTERNAME% >> %cd:~0,3%Migration\%computername%\%computername%.txt
	echo PROCESSEUR .......................: %PROCESSOR_ARCHITECTURE% >> %cd:~0,3%Migration\%computername%\%computername%.txt
	powershell -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=true' -ComputerName . | select IPAddress,DHCPEnabled | Format-Table" >> %cd:~0,3%Migration\%computername%\%computername%.txt
	echo Users >> %cd:~0,3%Migration\%computername%\%computername%.txt
	echo ------>> %cd:~0,3%Migration\%computername%\%computername%.txt
	dir "C:\USERS\" /W /b>> %cd:~0,3%Migration\%computername%\%computername%.txt
	echo. >> %cd:~0,3%Migration\%computername%\%computername%.txt
	exit