<#
.SYNOPSIS
Restores a backup of a database.
.DESCRIPTION
Given a local directory it restores all the databases from the directory  it searches recursely that fullfills the hardcoded filter eg  eCM_*.bak.
output from the script is a list of the databases that were restored.
Use parameter -Verbose to get more printed output.
.EXAMPLE
"T:\Buildbinge\beforeSEB100xPatches" | .\RestoreDB.ps1 -Verbose

.NOTES

Todo maybe add parameter to from the backup should be read now its hardcoded. Maybe add code that fixes all users that are not synked or warns about it.
.PARAMETER SQLServer
This is the servername with instancename  where data should be restored. Example "secc1619\TIMETest". Default is localhost
.PARAMETER BackupDirectory
This is the Name of the SQL SERVER database that should be restored. Example "T:\Buildbinge\beforeSEB100xPatches" it can be piped-. It is mandatory

#>
param  
(  
    [Parameter( 
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    [Alias('bu')] 
    [Alias('dir')] 
    [Alias('ds')] 
    [string]$BackupDirectory , 
    [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    [Alias('server')] 
    [Alias('s')] 
    [string]$SQLServer='localhost' 


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
           Write-Warning "Ending cant load sql smo run with debug true"
        Write-verbose "Problem with " $BackupFilePathName
                    write-verbose "Error text: " $_
                    write-verbose "Exception: " $_.Exception.GetType()   
                    write-Error "Error text: " $_
                    write-Error "Exception: " $_.Exception.GetType()

}
  
[Microsoft.SqlServer.Management.Smo.Server] $server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SQLServer 
#Check if the backupdirectory exist and if it seems taken with old backkupfiles create new backupdirectory
    if(!(test-path $BackupDirectory -pathtype container)) { Throw "Could not find the directory " + $BackupDirectory   }
$DatabaseList = @()
try{
foreach ($f in Get-ChildItem -path $BackupDirectory -recurse  -Filter eCM_*.bak | sort-object -Property fullname  )  {
        Write-verbose $f
        [Microsoft.SqlServer.Management.Smo.Restore] $smoRestore = new-object("Microsoft.SqlServer.Management.Smo.Restore")
        #settings for restore
        $smoRestore.NoRecovery = $false;
        $smoRestore.ReplaceDatabase = $true;
        $smoRestore.Action = "Database"
        $smoRestore.PercentCompleteNotification = 10;
        [Microsoft.SqlServer.Management.Smo.BackupDeviceItem]$backupDevice = New-Object ("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($f.fullname, "File")
        #set param so the PercentComplete notification is updated every 10 sec

        $smoRestore.Devices.Add($backupDevice)
        $ErrorActionPreference = "SilentlyContinue"
        #read db name, original sql server name and date from the backup file's backup header
        $smoRestoreDetails = $smoRestore.ReadBackupHeader($server)
        $DBNameFromBackup = $smoRestoreDetails.Rows[0]["DatabaseName"]
        $DatabaseList += $DBNameFromBackup
        $OriginalDBServer = $smoRestoreDetails.Rows[0]["ServerName"]
        $OriginalDBBackupDate = $smoRestoreDetails.Rows[0]["BackupFinishDate"] 
        $smoRestore.Database = $DBNameFromBackup
        $timestamp = Get-Date -format yyyyMMddHHmmss

        #restore
        Write-Verbose "Kill all connections to $DBNameFromBackup"
        $server.KillAllprocesses($DBNameFromBackup)
        Write-Verbose "Commence Restore Database:  $DBNameFromBackup at $timestamp from $OriginalDBServer at $OriginalDBBackupDate"
        $smoRestore.SqlRestore($server)
        }
      }
        catch{
        Write-Warning "Could not restore one or many databases run with debug true"
        Write-verbose "Problem with " $f
                    write-verbose "Error text: " $_
                    write-verbose "Exception: " $_.Exception.GetType()   
                    Write-Error "Problem with " $BackupFilePathName
                    write-Error "Error text: " $_
                    write-Error "Exception: " $_.Exception.GetType()       
}
#Return list of all restored databases name
$DatabaseList