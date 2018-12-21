@Echo Off
mode con cols=60 lines=15
color 8F

REM definition de l'ancien nom en variable	
	set "MIGRATIONDir=%cd:~0,3%Migration\%computername%"
	set "MIGRATIONLog=%cd:~0,3%Migration\%computername%\%computername%.txt"

	
IF "%1"=="firefox" goto firefox
IF "%1"=="carene" goto carene
IF "%1"=="signature" goto signature
IF "%1"=="bureau" goto bureau
IF "%1"=="import" goto import
goto exit


:firefox
	TITLE Transfert Profils Firefox (export)
	ECHO Transfert Profils Firefox (export)
	for /D %%D in ("C:\USERS\*") do (
		xcopy /I /Y /S "%%~fD\AppData\Roaming\Mozilla\Firefox\Profiles" "%MIGRATIONDir%\profils\%%~nxD\Mozilla\Firefox\Profiles"
	)
	EXIT
	
:carene	
	TITLE Transfert Profils carene (export)
	ECHO Transfert Profils carene (export)
	for /D %%D in ("C:\USERS\*") do (
		xcopy /I /Y /S "%%~fD\AppData\Roaming\carene\profil" "%MIGRATIONDir%\profils\%%~nxD\carene\profil"
	)
	EXIT
	
:signature
	TITLE Transfert Profils signature (export)
	ECHO Transfert Profils signature (export)
	for /D %%D in ("C:\USERS\*") do (
		xcopy /I /Y /S "%%~fD\AppData\Roaming\Microsoft\Signatures" "%MIGRATIONDir%\profils\%%~nxD\Microsoft\Signatures"
	)
	EXIT
	
:bureau	
	TITLE Transfert Profils bureau (export)
	ECHO Transfert Profils bureau (export)
	for /D %%D in ("C:\USERS\*") do (
		xcopy /y /s /e /d /h "%%~fD\Desktop\*.lnk" "%MIGRATIONDir%\profils\%%~nxD\Desktop\" /EXCLUDE:"%MIGRATIONDir%\_scripts\EXCLUDEFILE.TXT"
		xcopy /y /s /e /d /h "%%~fD\Desktop\*.url" "%MIGRATIONDir%\profils\%%~nxD\Desktop\"
	)
	EXIT
	
:import	
	TITLE Transfert Profils (Import)
	ECHO Transfert Profils (Import)

	REM on redéfinit les variables
	set "MIGRATIONDir=%cd:~0,3%Migration\%2"
	set "MIGRATIONLog=%cd:~0,3%Migration\%2\%2.txt"
	
	REM on liste les utilisateurs du nouveau poste
	for /D %%D in ("C:\USERS\*") do (
	
		REM pour chaque utilisateur du local on vérifie sa correspondance dans les dossiers stockés
		for /D %%E in ("%MIGRATIONDir%\profils\*") do (
				REM s'il y a correspondance on copie
				IF %%~nxE==%%~nxD (
				REM on compte le nombre de profils copiés
				set /a y+=1
				echo copie profils %%~nxE vers %%D
				xcopy /I /Y /S /q "%MIGRATIONDir%\profils\%%~nxD\carene\profil" "C:\USERS\%%~nxE\AppData\Roaming\carene\profil"
					attrib -A "C:\USERS\%%~nxE\AppData\Roaming\carene\profil"
				xcopy /I /Y /S /q "%MIGRATIONDir%\profils\%%~nxD\Mozilla\Firefox\Profiles" "C:\USERS\%%~nxE\AppData\Roaming\Mozilla\Firefox\Profiles"
				xcopy /I /Y /S /q "%MIGRATIONDir%\profils\%%~nxD\Signatures" "C:\USERS\%%~nxE\AppData\Roaming\Microsoft\Signatures"
				xcopy /I /Y /S /q "%MIGRATIONDir%\profils\%%~nxD\Desktop" "C:\USERS\%%~nxE\Desktop"
				)
		)
	)
	
	
REM on loggue la copie des profils
	echo. >> %MIGRATIONLog%
	echo Copie profils >> %MIGRATIONLog%
	echo -------------->> %MIGRATIONLog%

REM on affiche une sortie
	ECHO.
	IF defined y (
		echo NB PROFILS COPIES ...............: OK
		rem on loggue dans le fichier
		echo Nombre profils copies ...........: %Y% >> %MIGRATIONLog%

	) ELSE (
		echo NB PROFILS COPIES ...............: 0
		rem on loggue dans le fichier
		echo Nombre profils copies ...........: 0 >> %MIGRATIONLog%
	)
EXIT

		
