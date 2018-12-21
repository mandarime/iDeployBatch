@ECHO on
@ECHO off
mode con cols=60 lines=15
TITLE Transfert des profils (import USMT)
color 8F

REM definition de l'ancien nom en variable	
	set "oldcomputer=%1"
	set "MIGRATIONDir=%cd:~0,3%Migration\%oldcomputer%"
	set "MIGRATIONLog=%cd:~0,3%Migration\%oldcomputer%\%oldcomputer%.txt"

	REM on loggue le debut du LOADSTATE
	echo. >> %MIGRATIONLog%
	echo USMT LOADSTATE >> %MIGRATIONLog%
	echo --------------->> %MIGRATIONLog%
	echo HEURE DEBUT ..................: %TIME% >> %MIGRATIONLog%

:ToolkitVerif
	REM on définit en variable le chemin de USMT en fonction de l'archi
	if "%PROCESSOR_ARCHITECTURE%" == "x86" (
		set "USMTDir=C:\PROGRA~1\WI3CF2~1\10\ASSESS~1\USERST~1\x86\"
		set "USMTFile=C:\PROGRA~1\WI3CF2~1\10\ASSESS~1\USERST~1\x86\loadstate.exe"
	) ELSE (
		set "USMTDir=C:\PROGRA~2\WI3CF2~1\10\ASSESS~1\USERST~1\amd64\"
		set "USMTFile=C:\PROGRA~2\WI3CF2~1\10\ASSESS~1\USERST~1\amd64\loadstate.exe"
	)

	REM on vérifie si le toolkit est présent
	if exist "%USMTFile%" (
		REM on logue & on enchaine
		echo INSTALLATION TOOLKIT W10 .....: NON >> %MIGRATIONLog%
		goto :OkToolkit 
	) ELSE (
		REM on logue & on enchaine
		echo INSTALLATION TOOLKIT W10 .....: OUI >> %MIGRATIONLog%
		goto :NoToolkit
	)

REM si Toolkil absent, on l'installe
:NoToolkit
	cls
	ECHO _______________  Installation toolkit USMT  _______________
	ECHO.
	echo INSTALLATION TOOLKIT .........: En Cours
	start /wait %cd:~0,3%iDeployBatch\_usmtfiles\usmt.msi
		REM on logue & on enchaine
		echo INSTALLATION TOOLKIT CODE ....: %errorlevel% >> %MIGRATIONLog%

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
			pause
			GOTO :end
		) else ( 
			rem si pas de code d'erruer, on ecrit et on enchaine
			cls
			ECHO _______________  Installation toolkit USMT  _______________
			ECHO.
			echo INSTALLATION TOOLKIT .............: Reussie
			echo INSTALLATION TOOLKIT CODE ........: %errorlevel%
			timeout /t "4" >nul
		)

REM si toolkit présent on lance le loadstate
:OkToolkit
	REM on se positionne dans le bon répertoire
	cd /D %USMTDir%
	cls
	ECHO _______________  IMPORT des donnees USMT  ________________
	ECHO.
	loadstate %MIGRATIONDir% /c /lac
	
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
	