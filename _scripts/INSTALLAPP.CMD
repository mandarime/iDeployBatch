@ECHO on
@ECHO off
mode con cols=60 lines=15
TITLE ideployScript
color 8F

REM definition de l'ancien nom en variable	
	set "oldcomputer=%1"
	set "MIGRATIONDir=%cd:~0,3%Migration\%oldcomputer%"
	set "MIGRATIONLog=%cd:~0,3%Migration\%oldcomputer%\%oldcomputer%.txt"

REM on loggue les commandes
	echo. >> %MIGRATIONLog%
	echo Installation App metiers >> %MIGRATIONLog%
	echo ------------------------->> %MIGRATIONLog%

:selectapp
REM Prompt pour choisir machine concern‚e
	cls
	echo.
	ECHO ___________  INSTALLATION APPLICATIONS METIERS  ___________
	ECHO.
	ECHO Selectionner application Ã  installer ?
	ECHO 0. SORTIE
	ECHO.
	ECHO 1. MARCO
	ECHO 2. CARENE
	ECHO 3. IODAS
	ECHO 4. CYRENE
	ECHO 5. HORUS
	ECHO 6. GENESIS
	set /p select="-> " 

	if /I "%select%"=="1" (goto :MARCO)
	if /I "%select%"=="2" (goto :CARENE)
	if /I "%select%"=="3" (goto :IODAS)
	if /I "%select%"=="4" (goto :CYRENE)
	if /I "%select%"=="5" (goto :HORUS)
	if /I "%select%"=="0" (goto :END)

:MARCO
	start /WAIT %cd:~0,3%iDeployBatch\_appmetier\MARCO\install.cmd
	echo Marco ............................: OK >> %MIGRATIONLog%
	GOTO :selectapp
:CARENE
	start /WAIT %cd:~0,3%iDeployBatch\_appmetier\CARENE\install.cmd
	echo Carene ...........................: OK >> %MIGRATIONLog%
	GOTO :selectapp
:IODAS
	start /WAIT %cd:~0,3%iDeployBatch\_appmetier\IODAS\install.cmd
	echo Iodas ............................: OK >> %MIGRATIONLog%
	GOTO :selectapp
:CYRENE
	start /WAIT %cd:~0,3%iDeployBatch\_appmetier\CYRENE\install.cmd
	echo Cyrene ...........................: OK >> %MIGRATIONLog%
	GOTO :selectapp
:HORUS
	start /WAIT %cd:~0,3%iDeployBatch\_appmetier\HORUS\install.cmd
	echo Horus ...........................: OK >> %MIGRATIONLog%
	GOTO :selectapp
:GENESIS
	start /WAIT %cd:~0,3%iDeployBatch\_appmetier\GENESIS\install.cmd
	echo Genesis ..........................: OK >> %MIGRATIONLog%
	GOTO :selectapp
	
:END
	echo Fin des installations ............: %TIME% >> %MIGRATIONLog%
	exit

	
