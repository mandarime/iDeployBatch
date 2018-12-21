@ECHO on
@ECHO off
mode con cols=60 lines=15
TITLE ideployScript
color 8F

REM ***************************************************ELEVATION DROITS UAC********************************************************************************
	:admin
		>nul 2>&1 "%SYSTEMROOT%\system32\caCLS.exe" "%SYSTEMROOT%\system32\config\system"
		IF '%errorlevel%' NEQ '0' (
			ECHO.
			ECHO.
			ECHO ___________________   ideploy script   ____________________
			ECHO.
			ECHO.
			ECHO.
			ECHO.          Verification des privileges administrateur                                          
			ECHO.
			ECHO.                                                            
			ECHO ___________________________________________________________
			GOTO UACPrompt
		) ELSE ( GOTO gotAdmin )

		:UACPrompt
			ECHO SET UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
			SET params = %*:"="
			ECHO UAC.ShellExecute "%~s0", "%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

			"%temp%\getadmin.vbs"
			EXIT /B

		:gotAdmin
			IF exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
			pushd "%CD%"
			CD /D "%~dp0"

REM ***************************************************PROMPT QUESTION TYPE *******************************************************************************
	:question
		CLS
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO Selectionner type execution?
		ECHO 1.ANCIEN POSTE
		ECHO 2.NOUVEAU POSTE
		ECHO 3.Purger le disque
		ECHO 4.Quitter
		ECHO.
		SET /p choix="-> "
			IF /I "%choix%"=="1" (GOTO :ancien)
			IF /I "%choix%"=="2" (GOTO :checkPart)
			IF /I "%choix%"=="3" (GOTO :purgeFolder)
			IF /I "%choix%"=="4" (GOTO :end)
		GOTO question

REM ***************************************************ANCIEN POSTE****************************************************************************************
	:ancien
		CLS
		TITLE Ancien poste (en cours)
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %COMPUTERNAME%
		ECHO ARCHITECTURE .....................: %PROCESSOR_ARCHITECTURE%
		
	:folder
	rem creation d'un dossier de sauvegarde par poste
		ECHO CREATION DOSSIER MIGRATION .......: %cd:~0,3%Migration\%computername%
		MKDIR %cd:~0,3%Migration\%computername%
		timeout /t "1" >nul

	:file	
	rem ecriture d'un fichier recapitulatif
		ECHO CREATION FICHIER JOURNAL .........: %computername%.txt
		START /MIN %cd:~0,3%iDeployBatch\_scripts\IFILE.CMD
		timeout /t "3" >nul

	REM definition des noms en variable	
		SET "MIGRATIONDir=%cd:~0,3%Migration\%computername%"
		SET "MIGRATIONLog=%MIGRATIONDir%\%computername%.txt"

	:purgefichier
	REM on nettoie les fichiers temporaires
		START /wait %cd:~0,3%iDeployBatch\_scripts\SUPPRTEMP.CMD
		ECHO NETTOYAGE/PURGE FICHIERS .........: ok

	:altiris
	REM on desinstalle Altiris
		CD C:\PROGRA~1\ALTIRIS\ALTIRI~1\AeXAgentUtil.exe /uninstallagents /clean
		ECHO DESINSTALLATION ALTIRIS ..........: %errorlevel%
			rem on l'ecrit dans le fichiers
			ECHO. >> %MIGRATIONLog%
			ECHO ALTRIRIS >> %MIGRATIONLog%
			ECHO --------->> %MIGRATIONLog%
			ECHO Desinstallation ..................: %errorlevel% >> %MIGRATIONLog%
	
	:profilecopyIN	
	rem copie des profils roaming
		START /wait %cd:~0,3%iDeployBatch\_scripts\COPYPROFILE.CMD firefox
		ECHO COPIE PROFILS FIREFOX ............: OK

		START /wait %cd:~0,3%iDeployBatch\_scripts\COPYPROFILE.CMD carene
		ECHO COPIE PROFILS CARENE .............: OK

		START /wait %cd:~0,3%iDeployBatch\_scripts\COPYPROFILE.CMD signature
		ECHO COPIE PROFILS SIGNATURE ..........: OK

		START /wait %cd:~0,3%iDeployBatch\_scripts\COPYPROFILE.CMD bureau
		ECHO COPIE PROFILS BUREAU .............: OK
		
			rem on lit le contenu copier et on incr?mente un compteur
			FOR /D %%D IN ("%MIGRATIONDir%\profils\*") DO (
				IF EXIST %MIGRATIONDir%\profils\%%~nxD\Mozilla SET /A firefox+=1
				IF EXIST %MIGRATIONDir%\profils\%%~nxD\carene SET /A carene+=1
				IF EXIST %MIGRATIONDir%\profils\%%~nxD\Microsoft SET /A signature+=1
				IF EXIST %MIGRATIONDir%\profils\%%~nxD\Desktop SET /A bureau+=1
			)

			rem on l'ecrit dans le fichiers
			ECHO. >> %MIGRATIONLog%
			ECHO Copie profils >> %MIGRATIONLog%
			ECHO -------------->> %MIGRATIONLog%
			ECHO Profils firefox ..................: %firefox% >> %MIGRATIONLog%
			ECHO Profils carene ...................: %carene% >> %MIGRATIONLog%
			ECHO Signature Outlook ................: %signature% >> %MIGRATIONLog%
			ECHO Bureau (raccourcis) ..............: %bureau%  >> %MIGRATIONLog%

	:USMTExport
	rem lancement USMT
		ECHO TRANSFERT DONNEES ................: EN COURS
		ECHO Veuillez patientez jusqu'a la fermeture du programme.
		timeout /t "3" >nul
		START /wait %cd:~0,3%iDeployBatch\_scripts\USMTEXPORT.CMD %computername%

		REM Gestion code retour
		IF '%errorlevel%' NEQ '0' (
			SET USMTReturnCode=Echec - code %errorlevel%
			GOTO :DomainOUT
		) ELSE ( 
			SET USMTReturnCode=OK
		)
	:DomainOUT
		START /wait %cd:~0,3%iDeployBatch\_scripts\DOMAINOUT.CMD

		REM Gestion code retour
		IF '%errorlevel%' NEQ '0' (
			SET DOMAINReturnCode=Echec - code %errorlevel%
			GOTO :domainLog
		) ELSE ( 
			SET DOMAINReturnCode=OK
			GOTO :domainLog
		)
		:domainLog
		ECHO Resultat .........................: %DOMAINReturnCode% >> %MIGRATIONLog%
		ECHO. >> %MIGRATIONLog%
		ECHO FIN SCRIPT .......................: %TIME% >> %MIGRATIONLog%
		ECHO. >> %MIGRATIONLog%
		ECHO. >> %MIGRATIONLog%	
		ECHO. >> %MIGRATIONLog%

	:financienposte
		CLS
		TITLE Ancien poste (Termine)
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %COMPUTERNAME%
		ECHO ARCHITECTURE .....................: %PROCESSOR_ARCHITECTURE%
		ECHO CREATION FICHIER JOURNAL .........: %computername%.txt
		ECHO NETTOYAGE/PURGE FICHIERS .........: OK
		ECHO DESINSTALLATION ALTIRIS ..........: OK
		ECHO COPIE PROFILS ....................: OK
		ECHO TRANSFERT DONNEES ................: %USMTReturnCode%
		ECHO SORTIE DU DOMAINE ................: %DOMAINReturnCode%
		ECHO ___________________________________________________________
		ECHO Script termine
		pause>nul|SET/p =Appuyer sur une touche pour fermer la fenetre...
		GOTO :end
		
REM ***************************************************nouveau poste PART1 ********************************************************************************
	:checkPart
	REM on v?ifie quelle partie du script a lancer
		SET "ideployTempFile=%SystemRoot%\TEMP\iDeploy\ideploy.log"
		IF exist "%ideployTempFile%" GOTO :part2
	
	:return
	REM on prevoit la reinitialisation du prompt (purge ecran et variablee)
		CLS
		endlocal
		
	:nouveau
		CLS
		TITLE Nouveau poste - partie 1 (en cours)
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %COMPUTERNAME%

	:backupFolder
	REM lecture du dossier de stockage des machines
		SETlocal enabledelayedexpansion

		SET count=0
		for /D %%x in ("%cd:~0,3%Migration\*") do (
		  SET /a count=count+1
		  SET choice[!count!]=%%~nx
		)

	:selectsource
	REM Prompt pour choisir machine concern?e
		ECHO.
		ECHO _____________________   selection    ______________________
		ECHO Selectionner machine source ?
		for /l %%x in (1,1,!count!) do (
		   ECHO %%x. !choice[%%x]!
		)
		SET /p select="-> " 

	REM validation machine ou retour d?part
		ECHO.
		ECHO Vous avez selectionne : !choice[%select%]!
		ECHO Confirmez vous votre choix ? (O/N/Quit)
				SET /p confirm="-> "
				IF /I "%confirm%"=="o" (GOTO :oldConfirm)
				IF /I "%confirm%"=="n" (GOTO :return)
				IF /I "%confirm%"=="q" (GOTO :end)

	:oldConfirm
	REM definition des variable	
		SET oldcomputer=!choice[%select%]!
		SET "MIGRATIONDir=%cd:~0,3%Migration\%oldcomputer%"
		SET "MIGRATIONLog=%MIGRATIONDir%\%oldcomputer%.txt"

	:lognouveau
	REM on loggue les infos de la nouvelle machine
		ECHO. >> %MIGRATIONLog%
		ECHO ---------------------------- NOUVEAU POSTE ------------------------------------->> %MIGRATIONLog%
		ECHO DEBUT SCRIPT PART1 ...............: %TIME% >> %MIGRATIONLog%
		ECHO DATE .............................: %DATE% >> %MIGRATIONLog%
		ECHO UTILISATEEUR ACTIF ...............: %USERNAME% >> %MIGRATIONLog%
		ECHO NOM MACHINE ......................: %COMPUTERNAME% >> %MIGRATIONLog%
		ECHO PROCESSEUR .......................: %PROCESSOR_ARCHITECTURE% >> %MIGRATIONLog%
		
	:USMTimport
	REM on appelle le script d'import USMT
		CLS
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %oldcomputer% to %COMPUTERNAME%
		ECHO TRANSFERT DONNEES ................: EN COURS
		ECHO Veuillez patientez jusqu'a la fermeture du programme.
		timeout /t "4" >nul
		
		START /wait %cd:~0,3%iDeployBatch\_scripts\USMTIMPORT.CMD %oldcomputer%
		timeout /t "2" >nul

		REM Gestion code retour
		IF '%errorlevel%' NEQ '0' (
			SET USMTReturnCode=Echec - code %errorlevel%
			GOTO :financienposte
		) ELSE ( 
			SET USMTReturnCode=OK
		)
				
	:profilecopyOUT
	REM On copie en dur les elements manquants de l'usmt	
		CLS
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %oldcomputer% to %COMPUTERNAME%
		ECHO TRANSFERT DONNEES ................: %USMTReturnCode%

		REM on appelle le fichier
		START /wait %cd:~0,3%iDeployBatch\_scripts\COPYPROFILE.CMD import %oldcomputer%
		ECHO COPIE PROFILS ....................: OK

	:RenamePC
		START /wait %cd:~0,3%iDeployBatch\_scripts\RENAMEPC.CMD %oldcomputer%
		ECHO RENOMMAGE POSTE ..................: OK

	REM on active Windoxs
	:ActivationMS
		REM on loggue l'activatiion MS
		ECHO. >> %MIGRATIONLog%
		ECHO Activation microsoft >> %MIGRATIONLog%
		ECHO --------------------->> %MIGRATIONLog%
	
		START /WAIT %cd:~0,3%iDeployBatch\_scripts\ACTIVATEMS.CMD windows
			REM gestion du code retour
			IF '%errorlevel%' NEQ '0' (
				rem s'il y a un code erreur, on afiiche un message, on pause et on sort
				ECHO ACTIVATION WINDOWS ...............: KO - Code %errorlevel%
				ECHO ACTIVATION WINDOWS ...............: KO - code %errorlevel% >> %MIGRATIONLog%
				GOTO :ActivationOffice
			) ELSE ( 
				rem si pas de code d'erruer, on ecrit et on enchaine
				ECHO ACTIVATION WINDOWS ...............: OK
				ECHO ACTIVATION WINDOWS ...............: %errorlevel% >> %MIGRATIONLog%
			)

	:ActivationOffice		
		START /WAIT %cd:~0,3%iDeployBatch\_scripts\ACTIVATEMS.CMD office
			IF '%errorlevel%' NEQ '0' (
				rem s'il y a un code erreur, on afiiche un message, on pause et on sort
				ECHO ACTIVATION OFFICE ................: KO - Code %errorlevel%
				ECHO ACTIVATION OFFICE ................: KO - Code %errorlevel% >> %MIGRATIONLog%
				GOTO :MajGlobale
			) ELSE ( 
				rem si pas de code d'erruer, on ecrit et on enchaine
				ECHO ACTIVATION OFFICE ................: OK
				ECHO ACTIVATION OFFICE ................: %errorlevel% >> %MIGRATIONLog%
			)
			
	:MajGlobale
	REM on loggue les commandes
		ECHO. >> %MIGRATIONLog%
		ECHO MAJ Globales >> %MIGRATIONLog%
		ECHO ------------->> %MIGRATIONLog%

	REM MAJ GPO
		START /WAIT %cd:~0,3%iDeployBatch\_scripts\CMDGLOBALE.CMD GPUPDATE %oldcomputer%
		ECHO MAJ GPO ..........................: OK
		
		REM MAJ REGISTRY
		START /WAIT %cd:~0,3%iDeployBatch\_scripts\CMDGLOBALE.CMD REGEDIT %oldcomputer%
		REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\1-Versions /V Quadria /T REG_SZ /D %DATE% /f
		ECHO MAJ REGISTRY .....................: OK

		REM MAJ BIOS
		START /WAIT %cd:~0,3%iDeployBatch\_scripts\CMDGLOBALE.CMD BIOS %oldcomputer%
		ECHO MAJ BIOS .........................: OK

	:tempfilepart1
		REM on ajoute un fichier temporaire avec le nom de l'ancien poste dans le temp pour lancer la 2nde partie du script
		mkdir %SystemRoot%\TEMP\iDeploy
		ECHO %oldcomputer%>%SystemRoot%\TEMP\iDeploy\ideploy.log

		ECHO. >> %MIGRATIONLog%
		ECHO. >> %MIGRATIONLog%
		ECHO FIN SCRIPT PART1 .................: %TIME% >> %MIGRATIONLog%


		TITLE Nouveau poste - partie 1(Termine)
		ECHO ___________________________________________________________
		ECHO Script - partie 1 termine
		pause>nul|SET/p =Appuyer sur une touche pour red?marrer le poste...
		shutdown /r /t 15
		GOTO :end


	
REM ***************************************************nouveau poste part2 ********************************************************************************
	:part2
		REM je recupere le nom de l'ancien poste
		SET "ideployTempFile=%SystemRoot%\TEMP\iDeploy\ideploy.log"
		for /f "delims=" %%a in (%ideployTempFile%) do SET oldcomputer=%%a
		
		REM definition de l'ancien nom en variable	
		SET "MIGRATIONDir=%cd:~0,3%Migration\%oldcomputer%"
		SET "MIGRATIONLog=%cd:~0,3%Migration\%oldcomputer%\%oldcomputer%.txt"

		REM je loggue
		ECHO. >> %MIGRATIONLog%
		ECHO DEBUT SCRIPT PART2 ...............: %TIME% >> %MIGRATIONLog%
		ECHO UTILISATEEUR ACTIF ...............: %USERNAME% >> %MIGRATIONLog%

		REM on purge l'ecran et on affiche le s?quenceur
		CLS
		TITLE Nouveau poste - partie 2 (en cours)
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %oldcomputer% to %COMPUTERNAME%
		ECHO INSATALLATION APP METIER .........: En cours

	:applications		
		START /WAIT %cd:~0,3%iDeployBatch\_scripts\INSTALLAPP.CMD %oldcomputer%
		CLS
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %oldcomputer% to %COMPUTERNAME%
		ECHO INSATALLATION APP METIER .........: OK
		ECHO MAJ IDEPLOY ......................: En cours

	:ideploy		
		"C:\Program Files\Mozilla Firefox\firefox.exe" -private-window http://pt109323.dept34.intranet/ideploy/
		CLS
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO DATE .............................: %DATE% %TIME%
		ECHO NOM MACHINE ......................: %oldcomputer% to %COMPUTERNAME%
		ECHO INSATALLATION APP METIER .........: OK
		ECHO MAJ IDEPLOY ......................: OK
	
	:supprTempFolder
		rmdir /s /q %SystemRoot%\TEMP\iDeploy
		ECHO SUPPRESSION TEMPORAIRE ...........: OK
		timeout /t "3" >nul
		ECHO FIN SCRIPT PART2 .................: %TIME% >> %MIGRATIONLog%

		
		TITLE Nouveau poste - partie (Termine)
		ECHO ___________________________________________________________
		ECHO.
		ECHO Script termine avec succes
		ECHO Pensez ? installer les applications etageres 
		ECHO et les peipheriques !
		PAUSE

			
REM ***************************************************FIN DU PROGRAMME ***********************************************************************************
	:end
		CLS
		TITLE FERMETURE
		COLOR 8F
		ECHO.
		ECHO.
		ECHO ___________________   ideploy script   ____________________
		ECHO.
		ECHO                  AUTEUR.......: JFMACART
		ECHO                  VERSION......: 3
		ECHO                  DATE RELEASE : 2018-12-10
		ECHO.                     
		ECHO ___________________________________________________________
		SET /p ".=Fin du programme dans 2 secondes " <nul
		timeout /t "1" >nul
		SET /p ".=." <nul
		timeout /t "1" >nul
		SET /p ".=." <nul
		timeout /t "1" >nul
		SET /p ".=Bye !" <nul
		timeout /t "1" >nul

