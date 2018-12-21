@ECHO on
@ECHO off
mode con cols=60 lines=15
TITLE Transfert des profils (export USMT)
color 8F

REM definition de l'ancien nom en variable	
	set "MIGRATIONDir=%cd:~0,3%Migration\%computername%"
	set "MIGRATIONLog=%cd:~0,3%Migration\%computername%\%computername%.txt"

REM on loggue le debut du scanstate
	echo. >> %MIGRATIONLog%
	echo USMT SCANSTATE >> %MIGRATIONLog%
	echo --------------->> %MIGRATIONLog%
	echo HEURE DEBUT ......................: %TIME% >> %MIGRATIONLog%
	

:ToolkitVerif
	REM on définit en variable le chemin de USMT en fonction de l'archi
	if "%PROCESSOR_ARCHITECTURE%" == "x86" (
		set "USMTDir=C:\PROGRA~1\WI3CF2~1\10\ASSESS~1\USERST~1\x86\"
		set "USMTFile=C:\PROGRA~1\WI3CF2~1\10\ASSESS~1\USERST~1\x86\scanstate.exe"
	) ELSE (
		set "USMTDir=C:\PROGRA~2\WI3CF2~1\10\ASSESS~1\USERST~1\amd64\"
		set "USMTFile=C:\PROGRA~2\WI3CF2~1\10\ASSESS~1\USERST~1\amd64\scanstate.exe"
	)

	REM on vérifie si le toolkit est présent
	if exist "%USMTFile%" (
		REM on logue & on enchaine
		echo INSTALLATION TOOLKIT W7 ..........: NON >> %MIGRATIONLog%
		goto :OkToolkit
	) ELSE (
		REM on logue & on enchaine
		echo INSTALLATION TOOLKIT W7 ..........: OUI >> %MIGRATIONLog%
		goto :NoToolkit
	)

REM si Toolkil absent, on l'installe et on logue
:NoToolkit
	cls
	ECHO _______________  Installation toolkit USMT  _______________
	ECHO.
	echo INSTALLATION TOOLKIT .............: En cours
	start /wait %cd:~0,3%iDeployBatch\_usmtfiles\usmt.msi

		REM gestion du code retour
		if '%errorlevel%' NEQ '0' (
			rem s'il y a un code erreur, on afiiche un message, on pause et on sort
			cls
			ECHO _______________  Installation toolkit USMT  _______________
			ECHO.
			echo INSTALLATION TOOLKIT .............: Echec
			echo INSTALLATION TOOLKIT CODE ........: %errorlevel%
			echo.
			echo une erreur s'est produite lors de l'installation.
			ECHO Veuillez relancer le script ou contacter l'administrateur.
			ECHO.
			REM on logue & on enchaine
			ECHO INSTALLATION TOOLKIT CODE ........: Echec - Code %errorlevel% >> %MIGRATIONLog%
			pause
			GOTO :end
		) else ( 
			rem si pas de code d'erruer, on ecrit et on enchaine
			cls
			ECHO _______________  Installation toolkit USMT  _______________
			ECHO.
			echo INSTALLATION TOOLKIT .............: Reussie
			echo INSTALLATION TOOLKIT CODE ........: %errorlevel%
			REM on logue & on enchaine
			ECHO INSTALLATION TOOLKIT CODE ........: Reussie >> %MIGRATIONLog%
			timeout /t "4" >nul
		)

REM si toolkit présent on lance le loadstate
:OkToolkit
	REM on se positionne dans le bon répertoire
	cd /D %USMTDir%
	cls
	ECHO _______________  EXPORT des donnees USMT  ________________
	scanstate %MIGRATIONDir% /ue:DEPT34\lmendy /ue:DEPT34\pfau /ue:DEPT34\brobigeau /ue:DEPT34\nazzoug /ue:DEPT34\ydiemunsch /ue:DEPT34\abarrisset /ue:DEPT34\vhdservices /ue:DEPT34\script /ue:DEPT34\quadria /ue:DEPT34\Public /ue:DEPT34\phpdervices /ue:DEPT34\bgerard /ue:DEPT34\adm* /ue:DEPT34\adm* /ue:%computername%\Adm* /i:MigUser.xml /o /c 

		REM gestion du code retour
		if '%errorlevel%' NEQ '0' (
			ECHO TRANSFERT DES DONNEES ............: Echec >> %MIGRATIONLog%
			ECHO USMT CODE RETOUR .................: %errorlevel% >> %MIGRATIONLog%
			GOTO :end
		) else ( 
			ECHO TRANSFERT DES DONNEES ............: Reussi >> %MIGRATIONLog%
			ECHO USMT CODE RETOUR .................: %errorlevel% >> %MIGRATIONLog%
		)

:end	
	echo HEURE FIN ........................: %TIME% >> %MIGRATIONLog%

exit
