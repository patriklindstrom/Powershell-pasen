<# 
.SYNOPSIS 
Backups a set of SQL Server databases with similar name. 
.DESCRIPTION 
All Databases that starts with the name eCM can be backed up to a single folder.  ending with .sql will recursivly be run against localhost sqlserver or the sqlserver given in parameter $SQLServer. If a SQL file generates a

sql error its extension it can be changed from .sql to .failed this is so this file will not be run again on a rerun. 
The script outpus an path of where the files are 
.EXAMPLE 
.\Backup-sql.ps1 -BackupDirectory "T:\Version6OfDevDB\" 
.EXAMPLE 
Pipe directory "T:\PutMyBaselineOFDBHere\"|.\Backup-sql.ps1 -DatabaseNamePattern "eCM*" 
.PARAMETER BackupDirectory

.PARAMETER DatabaseNamePattern

.PARAMETER ReadMe


.LINK 
latest version 
http://github.com/patriklindstrom/Powershell-pasen 
.LINK 
About Author and script 
http://www.lcube.se 
.LINK 
About powershell for SQL Server 
http://msdn.microsoft.com/en-us/library/hh245198.aspx 
.LINK 
#http://msdn.microsoft.com/en-us/library/dd938892(SQL.100).aspx 
.NOTES 
    File Name  : backup-sql.ps1 
    Author     : Patrik Lindström LCube 
    Requires   : PowerShell V2 CTP3 
These snapins must have been installed before you can run this powershell. They should come with sqlserver 2008 or should be avaible from Microsoft.

 sqlserverprovidersnapin100 
 sqlservercmdletsnapin100 
#>

param  
(  [Parameter( 
        Mandatory=$true, 
        Position=0, 
        ValueFromPipeLine=$true, 
        ValueFromPipelineByPropertyName=$true)] 
    [Alias("d")] 
    [Alias("dir")] 
    [string]$BackupDirectory , 
     [Parameter( 
        Mandatory=$false, 
        Position=1, 
        ValueFromPipeLine=$false, 
        ValueFromPipelineByPropertyName=$true)] 
    [Alias("db")] 
    [string]$DatabaseNamePattern ="eCM*" , 
         [Parameter( 
        Mandatory=$false, 
        Position=2, 
        ValueFromPipeLine=$false, 
        ValueFromPipelineByPropertyName=$true)] 
    [Alias("comment")] 
    [Alias("c")] 
    [string]$ReadMe 
    
) 
    if ($verbose) {$VerbosePreference = "Continue"}  
    if ($debug) {$DebugPreference = "Stop"} 
try {   [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null 
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SmoExtended') | out-null 
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null 
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null 
        [Microsoft.SqlServer.Management.Smo.Server] $s = new-object ('Microsoft.SqlServer.Management.Smo.Server') "localhost"

        $TestOfSmo = $s.Settings.BackupDirectory 
        if (!$TestOfSmo){ Throw "Could Not load and handle Loading of SQLServer.SMO wich is needed" } 
    } 
   catch{ 
        Throw "Ending cant load sql smo"   
} 
    
$dbs = $s.Databases 
# Iterate through all databases and backup each user database 
try{ 
#Check if the backupdirectory exist and if it seems taken with old backkupfiles create new backupdirectory 
    if(!(test-path $BackupDirectory -pathtype container)){new-item $BackupDirectory -type directory} 
        elseif( (get-childItem $BackupDirectory\\eCM_*.bak)) 
        { 
            $BackupDirectory =  $BackupDirectory.Trimend('\\') 
            $BackupDirectory += get-date -format yyyyMMddHHmmss     
            new-item $BackupDirectory -type directory 
        } 
    } 
catch{ 
        Throw "Could not create or find the directory " + $BackupDirectory   
} 
$ErrorActionPreference = "SilentlyContinue"


try{ 
$dbs|Where-Object{$_.Name -like $DatabaseNamePattern}| foreach-object { 
              $dbbk = new-object ('Microsoft.SqlServer.Management.Smo.Backup') 
              $dbbk.Action = 'Database' 
              $dbbk.BackupSetDescription = "Full copy only backup of TCM on $s.name " 
              $dbbk.BackupSetName = $_.Name + " Backup" 
              $dbbk.Database = $_.Name 
              $dbbk.CopyOnly = $TRUE 
              $dbbk.MediaDescription = "Disk" 
              $BackupFilePathName = join-path -Path $BackupDirectory -ChildPath ($_.Name + ".bak") 
              Write-Verbose $BackupFilePathName 
              $dbbk.Devices.AddDevice($BackupFilePathName, 'File') 
              # compression does not work because this isa cheap SQL Server 2008 not a R2 
             # $dbbk.CompressionOption = "1" 
             # $smo.KillAllProcesses($_.Name) 
              $dbbk.SqlBackup($s)       
        } 
   } 
catch{ 
        Write-Warning "Could not backup one or many databases run with debug true" 
        Write-verbose "Problem with " $BackupFilePathName 
                      write-verbose "Error text: " $_ 
                    write-verbose "Exception: " $_.Exception.GetType()   
                    Write-Error "Problem with " $BackupFilePathName 
                    write-Error "Error text: " $_ 
                    write-Error "Exception: " $_.Exception.GetType() 
      

} 
#Return the path where the backupfiles are 
$BackupDirectory