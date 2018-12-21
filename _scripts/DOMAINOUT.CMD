@ECHO on
@ECHO off
TITRE Sortie du domaine
mode con cols=60 lines=15
color 8F

REM definition de l'ancien nom en variable	
	set "MIGRATIONDir=%cd:~0,3%Migration\%computername%"
	set "MIGRATIONLog=%cd:~0,3%Migration\%computername%\%computername%.txt"

	rem ON LOGGUE
	ECHO. >> %MIGRATIONLog%
	ECHO Sortie du domaine >> %MIGRATIONLog%
	ECHO ------------------>> %MIGRATIONLog%
	
	REM on crée un nouvel utilisateur
	net user quadriadmin vendredi34! /ADD
		REM gestion du code retour
		IF '%errorlevel%' NEQ '0' (
			ECHO Création nouvel user .............: KO  - Code %errorlevel% >> %MIGRATIONLog%
		) ELSE ( 
			ECHO Création nouvel user .............: quadriadmin >> %MIGRATIONLog%
		)

	REM on positionne le nouvel user admin	
	net localgroup Administrateurs quadriadmin /add
		REM gestion du code retour
		IF '%errorlevel%' NEQ '0' (
			ECHO Droits administrateur local ......: KO  - Code %errorlevel% >> %MIGRATIONLog%
		) ELSE ( 
			ECHO Droits administrateur local ......: OK >> %MIGRATIONLog%
		)

	REM on "sort" le poste du domaine 	
	powershell -Command "Add-Computer -WorkGroupName 'SORTIE'" 
EXIT
	