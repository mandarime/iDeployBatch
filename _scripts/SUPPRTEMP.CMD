@Echo Off
mode con cols=60 lines=15
TITLE Nettoyage Windows
color 8F

REM definition de l'ancien nom en variable	
	set "MIGRATIONDir=%cd:~0,3%Migration\%computername%"
	set "MIGRATIONLog=%cd:~0,3%Migration\%computername%\%computername%.txt"

	REM on loggue la copie des profils
	echo. >> %MIGRATIONLog%
	echo Purge temporaires >> %MIGRATIONLog%
	echo ------------------>> %MIGRATIONLog%

REM on affiche une sortie
		echo Nombre profils copies ...........: %Y% >> %MIGRATIONLog%

		
		DEL /F /S /Q "C:\Windows\Temp\*.*"
		DEL /F /S /Q "c:\windows\prefetch\*.*"
		DEL /F /S /Q "%userprofile%\AppData\Local\Temp\*.*"
		echo Fichiers windows ................: OK >> %MIGRATIONLog%

		DEL /F /S /Q "%userprofile%\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*"
		DEL /F /S /Q "%userprofile%\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.ie5\*.*"	
		echo Fichiers IE .....................: OK >> %MIGRATIONLog%
	
		set ChromeDir=C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Cache
		del /q /s /f "%ChromeDir%"
		rd /s /q "%ChromeDir%"	
		echo Fichiers chrome .................: OK >> %MIGRATIONLog%
			
		RD /s /q "C:\pckg34"
		echo Fichiers PCKG34 .................: OK >> %MIGRATIONLog%
		
		REM RD /s /q "C:\Old_C"
		REM RD /s /q "C:\Old_D"

	EXIT