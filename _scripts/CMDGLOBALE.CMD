@ECHO on
@ECHO off
mode con cols=60 lines=15
color 8F

REM definition de l'ancien nom en variable	
	set "oldcomputer=%2"
	set "MIGRATIONDir=%cd:~0,3%Migration\%oldcomputer%"
	set "MIGRATIONLog=%cd:~0,3%Migration\%oldcomputer%\%oldcomputer%.txt"

REM on récupére le paramètre et on go to	
	IF "%1"=="GPUPDATE" goto GPUPDATE
	IF "%1"=="REGEDIT" goto REGEDIT
	IF "%1"=="BIOS" goto BIOS
	goto exit


:GPUPDATE
	TITLE MAJ strategie locale (GPUPDATE)
		echo N | gpupdate /force
		echo MAJ Strategie locale ............: OK >> %MIGRATIONLog%
	EXIT
	
:REGEDIT	
	TITLE MAJ Registry (REGEDIT)
		regedit.exe /S %cd:~0,3%iDeployBatch\_scripts\UACRESEAU.REG
		echo MAJ registry ....................: OK >> %MIGRATIONLog%
	EXIT
	
:BIOS
	TITLE MAJ Bios (BIOS)
		start %cd:~0,3%iDeployBatch\_scripts\bios.exe
		echo MAJ BIOS ........................: OK >> %MIGRATIONLog%
	EXIT
	