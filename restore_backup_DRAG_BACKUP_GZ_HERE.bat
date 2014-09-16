@ECHO OFF

SET BaseDir=C:\Customers\*****YOURPROJECT*****
SET pgBaseDir=C:\Program Files\PostgreSQL\9.3\bin
SET PGHOST=localhost
SET PGPORT=5432
SET DATABASE=*****DATABASE->Lowercase!*****
SET PGUSER=postgres
SET PGPASSWORD=*****YOURPASS*****

SET pgCommand="%pgBaseDir%\psql.exe" 
SET pgRestore="%pgBaseDir%\pg_restore.exe" 
SET pgCreate="%pgBaseDir%\createdb.exe" 
SET pgDump="%pgBaseDir%\pg_dump.exe" 
SET pgDrop="%pgBaseDir%\dropdb.exe" 
SET DeploymentDir="%BaseDir%\Deployment"
SET DataDir="%DeploymentDir%\data\files"
SET zipCommand="%BaseDir%\7za.exe" 
SET BackupFileWithFullPath=%1
SET Backupfile=%~n1
SET BackupfileName=%Backupfile:.tar=%
SET BackupfileName=%BackupfileName:-=%
SET BackupPath=%~d1%~p1

rem Get the time from WMI - at least that's a format we can work with
set X=
for /f "skip=1 delims=" %%x in ('wmic os get localdatetime') do if not defined X set X=%%x

rem dissect into parts
set DATE.YEAR=%X:~0,4%
set DATE.MONTH=%X:~4,2%
set DATE.DAY=%X:~6,2%
set DATE.HOUR=%X:~8,2%
set DATE.MINUTE=%X:~10,2%
set DATE.SECOND=%X:~12,2%
set DATE.FRACTIONS=%X:~15,6%
set DATE.OFFSET=%X:~21,4%
SET DATETIME=%DATE.YEAR%_%DATE.MONTH%_%DATE.DAY%_%DATE.HOUR%_%DATE.MINUTE%

ECHO ---------------------------------------------------------------------------------------
ECHO -            APPRONTO, Business Apps Now!
ECHO -            www.appronto.nl
ECHO -
ECHO -            Backupfile:    %BackupFileWithFullPath%
ECHO -            BaseDir:       %BaseDir%
ECHO -            Database host: %PGHOST%:%PGPORT% (connect as %PGUSER%)
ECHO -            Database:      %DATABASE% (MUST be lowercase!)
ECHO -
ECHO ---------------------------------------------------------------------------------------
ECHO Continue?

pause

ECHO START: %DATETIME%_%DATE.SECOND%
ECHO ---------------------------------------------------------------------------------------
ECHO Extract downloaded full backup file with overwrite
%zipCommand% x %BackupFileWithFullPath% -aoa > extract1.txt
del extract1.txt

ECHO Extract extracted file with overwrite
%zipCommand% x %Backupfile% -aoa > extract2.txt
del extract2.txt

ECHO Disconnect database
%pgCommand% -h %PGHOST% -U %PGUSER% -o disconnect.txt -c "select pg_terminate_backend(pid) from pg_stat_activity where datname='%DATABASE%';"	
del disconnect.txt

ECHO Execute rename database %DATABASE% tot %DATABASE%_%DATETIME%
%pgCommand% -h %PGHOST% -U %PGUSER% -d postgres -o rename1.txt -c "ALTER DATABASE "%DATABASE%" RENAME TO "%DATABASE%_%DATETIME%";"	
del rename1.txt

ECHO Backup database %DATABASE%_%DATETIME% to %DATABASE%_%DATETIME%.backup
%pgDump% -f %DATABASE%_%DATETIME%.backup %DATABASE%_%DATETIME% 

ECHO Create database %DATABASE%
%pgCreate% %DATABASE%

ECHO Execute restore database from backupfile
%pgRestore% -d %DATABASE% db/db.backup >output.txt 2>&1 
del output.txt

ECHO Delete database files from directory

del /s /q db\*
rmdir /s /q db
del /s /q %Backupfile%

ECHO copy backup files to deployment data/files (%BackupPath%tree\ to %BaseDir%\deployment\data\files 
XCOPY "%BackupPath%tree\*" "%BaseDir%\deployment\data\files" /S /I /Y /Q

ECHO Delete %BackupPath%\tree directory
rd /s /q "%BackupPath%\tree"

ECHO 7zip backup %DATABASE%_%DATETIME%.backup to %DATABASE%_%DATETIME%.7z
%zipCommand% a -t7z  %DATABASE%_%DATETIME%.7z %DATABASE%_%DATETIME%.backup

ECHO Delete backup %DATABASE%_%DATETIME%.backup
del %DATABASE%_%DATETIME%.backup

rem Get the time from WMI - at least that's a format we can work with
set Y=
for /f "skip=1 delims=" %%Y in ('wmic os get localdatetime') do if not defined Y set Y=%%Y

rem dissect into parts
set DATEY.YEAR=%Y:~0,4%
set DATEY.MONTH=%Y:~4,2%
set DATEY.DAY=%Y:~6,2%
set DATEY.HOUR=%Y:~8,2%
set DATEY.MINUTE=%Y:~10,2%
set DATEY.SECOND=%Y:~12,2%
set DATEY.FRACTIONS=%Y:~15,6%
set DATEY.OFFSET=%Y:~21,4%
SET DATETIME_END=%DATEY.YEAR%_%DATEY.MONTH%_%DATEY.DAY%_%DATEY.HOUR%_%DATEY.MINUTE%_%DATEY.SECOND%
ECHO ---------------------------------------------------------------------------------------
ECHO Start: %DATETIME%_%DATE.SECOND%
ECHO End  : %DATETIME_END%
pause





