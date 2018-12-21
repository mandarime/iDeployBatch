@ECHO on
@ECHO off
mode con cols=60 lines=15
TITLE Renommage du PC
color 8F

	REM definition de l'ancien nom en variable	
		set "oldcomputer=%1"
		set "MIGRATIONDir=%cd:~0,3%Migration\%oldcomputer%"
		set "MIGRATIONLog=%cd:~0,3%Migration\%oldcomputer%\%oldcomputer%.txt"

	:RenamePCLogs
		REM on loggue le renommage du poste
		echo. >> %MIGRATIONLog%
		echo Renomage poste >> %MIGRATIONLog%
		echo --------------->> %MIGRATIONLog%

	:RenamePCQuestion
		CLS
		ECHO ____________________   RENOMMAGE POSTE   __________________
		ECHO.
		ECHO le nom de la machine doit avoir les 6 chiffres de l'etiquette
		ECHO et le prefixe suivant :
		ECHO PC pour les bureautiques - PT pour les techniques - PN pour les portables
		ECHO exemple : PC123456
		ECHO.
		ECHO NOM MACHINE ACTUEL ...............: %COMPUTERNAME%
		ECHO.
		set /p validateManualAsset="Souhaitez-vous renommer le poste ? (o/n) "
			if /I "%validateManualAsset%"=="o" (goto :RenamePC)
			if /I "%validateManualAsset%"=="n" (goto :RenameNO)
			
	:RenamePC
		CLS
		ECHO ____________________   RENOMMAGE POSTE   __________________
		REM on récupére l'assetTag depuis le BIOS via PS et on le stocke en variable
		for /f "delims=" %%i in ('powershell -Command "(Get-WmiObject Win32_SystemEnclosure).SMBiosAssetTag"') do Set AssetNumber=%%i

		:ifexistAsset
		REM on vérifie si l'assetTag existe
		IF defined AssetNumber (
			REM si l'assetTag existe, on enchaine
			GOTO :questionmat
		) ELSE (
			REM si l'assetTag n'existe pas, on demande … l'utilisateur de le saisir et on redéfinit la variable
			ECHO !       L'AssetTag n'est pas disponible dans le BIOS      !
			ECHO.
			set /p AssetNumber="Saisir le numero d'etiquette : "
			GOTO :questionmat
		)


		:WrongNB
		REM on affiche la possibilité de saisir un nom personnalisé en casde pb avec l'asset
			Set AssetNumber=
			set /p ComputerName1="Saisir le numero le nom machine complet (ex: PC123456) : "
			GOTO :validateTag

		REM on demande … l'utilisateur de choisir le type de matériel
		:questionmat
			CLS
			ECHO ____________________   RENOMMAGE POSTE   __________________
			ECHO                     (ASSET TAG :  %AssetNumber%)
			ECHO.
			ECHO Selectionner type materiel :
			ECHO 1.BUREAUTIQUE
			ECHO 2.TECHNIQUE
			ECHO 3.PORTABLE
			ECHO 4.SAISIE MANUELLE
			ECHO.
			
			REM en fonction du choix, on applique la convention de nommage et on définit le computername en variable
			set /p choix="-> "
				if /I "%choix%"=="1" (Set ComputerName1=PC%AssetNumber%)
				if /I "%choix%"=="2" (Set ComputerName1=PT%AssetNumber%)
				if /I "%choix%"=="3" (Set ComputerName1=PN%AssetNumber%)
				if /I "%choix%"=="4" (goto :WrongNB)
			
			REM on demande … l'utilisateur de valider son schoix, sinon retour au début du renommage
			:validateTag
			CLS
			ECHO ____________________   RENOMMAGE POSTE   __________________
			ECHO.
			ECHO Nouveau nom machine : %ComputerName1%
			ECHO.
				set /p validateManualAsset="Validez-vous votre choix ? (o/n) "
					if /I "%validateManualAsset%"=="o" (goto :rename)
					if /I "%validateManualAsset%"=="n" (
						Set AssetNumber=
						goto :RenamePC
					)

			:rename
			REM on execute la commande WMIC pour renommer le poste
			WMIC computersystem where caption="%computername%" rename "%ComputerName1%"

				rem on loggue dans le fichier
				echo RENOMAGE POSTE ...................: Oui >> %MIGRATIONLog%
				echo ANCIEN NOM .......................: %computername% >> %MIGRATIONLog%
				echo NOUVEAU NOM ......................: %ComputerName1% >> %MIGRATIONLog%
				ECHO.
				GOTO :end

	:RenameNO
		REM on loggue dans le fichier
		echo RENOMAGE POSTE ...................: non >> %MIGRATIONLog%

	:end
		EXIT
