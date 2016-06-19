<# 
.SYNOPSIS 
Renames and copy files to new directory so they become attractive to pick up for other system for further process. 
.DESCRIPTION 
It scans  RootPath\ExternalDropPath and copies them with new filename that contains old path and timestamp in ISO ISO_8601 with time offset from UTC 
and original filename according to hardcoded rules to RootPath\InternalPickupPath.
This so other polling system can be pick them up.
If this suceeds it also copies them to a RootPath\HistoryPath. If Log switch is turned on it logs all to eventlog. It could  be run every 1 min by windows task scheduler.
Run it with -Verbose switch if you want information in the console. Output of script is the path to the history folder if you want to pipe that info further.
You can use setupTestRename.ps1 to set up test files and try to run it. like .\setupTestRename.ps1 | .\Rename-Msg.ps1 -Verbose

.EXAMPLE 
 Simple run .\Rename-Msg.ps1 -Rootpath D:\FTPImport 
.EXAMPLE 
Pipe where to check for directory log to powershell eventlog  
"D:\FTPImport"|.\Rename-Msg.ps1 -Log
.EXAMPLE 
 Set where to recursivly search for files. Using order of params and log it. Write a log of extra info 
 .\Rename-Msg.ps1 "D:\FTPImport" "OtherSystemDropArea" -Log -Verbose
.EXAMPLE 
Pipe where to check for directory log to powershell eventlog files that has been moved are archived in Archive_2016  
"D:\FTPImport"|.\Rename-Msg.ps1 -HistoryPath "Archive_2016" 
.EXAMPLE 
Folder to scan for data is Hollywood.  Folder where it should put the files for other system is Artist and where it should  make archives is called Done. Switch to log to eventlog  
"D:\FTPImport" |.\Rename-Msg.ps1 -ext "Hollywood" -pickup "Artist" -hist "Done" -Log
.PARAMETER RootPath 
Path to the root of the all the file structure . Alias is p as in Path.
.PARAMETER ExternalDropPath 
Path to where to start looking for files under the Root path Default is data. Alias is ext.
.PARAMETER InternalPickupPath 
Path under the Root path to where to copy files for other Importing system to take action.  Default subfolder is cft. Alias is pickup.
.PARAMETER HistoryPath 
Path under the Root path to where to archive files that have been successfully moved and renamed files.  Default is history. Alias is history.
.PARAMETER DoLogIt
If the script should log what happens to the eventlogg for powershell. The default is that there should be no logging. Alias is log 
.INPUTS
          A System.String with a valid RootPath or an object  with a $RootPath member. 
          "D:\FTPImport"|.\Rename-Msg.ps1
.OUTPUTS
System.String. The Historyfolder path.
.LINK 
Latest version 
http://github.com/patriklindstrom/Powershell-pasen
.LINK 
Links to help how to execute a powershell script automatically using windows task scheduler
http://stackoverflow.com/questions/23953926/how-to-execute-a-powershell-script-automatically-using-windows-task-scheduler
https://blogs.technet.microsoft.com/heyscriptingguy/2012/08/11/weekend-scripter-use-the-windows-task-scheduler-to-run-a-windows-powershell-script/
https://support.software.dell.com/appassure/kb/144451
.LINK
How to use event like file added to folder instead of scheduling to run script. Bit more complicated
https://gallery.technet.microsoft.com/scriptcenter/Powershell-Script-to-3b984f02

.NOTES 
    File Name  : Rename-Msg.ps1 
    Author     : Patrik Lindström LCube 
#> 
param  
(  
    [Parameter( 
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('path')] 
    [string]$RootPath='C:\myc\BuildBinge\Ahl\Gossips' ,
    [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('ext')] 
    [string]$ExternalDropPath='\data' 
    ,
    [Parameter( 
        Position=2, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 

    [Alias('pickup')] 
    [string]$InternalPickupPath='\cft' 
    ,
    [Parameter( 
        Position=3, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('history')] 
    [string]$HistoryPath='\history' 
    , 
        [Parameter( 
        Position=4, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('log')] 
    [switch] $DoLogIt 
     )

     # To abstract the logging to whatever you want. Here I use Eventlog and Powershell log.
     # you could change to use application log or write to file instead.
     # see eg http://www.computerperformance.co.uk/powershell/powershell_write_eventlog.htm
     # or https://blogs.technet.microsoft.com/heyscriptingguy/2013/06/20/how-to-use-powershell-to-write-to-event-logs/
     # 
     function LogIt ($Level, $Message ,$Id, $LogIt)
     { $DateString = Get-Date  -format "yyyyMMddTHHmmssfffzz"
        Write-Verbose "$DateString `t $Message" 
        if ($LogIt)
        { # to list eventlogs you could write to : Get-EventLog -list else you have to register or use Application log
            Write-Eventlog  -Logname 'Windows PowerShell' -Source 'PowerShell' `
            -EventID $Id -EntryType $Level -Message  $Message
        }
     }
     #It gives new fileName and copies to both the pickup place and the history all in one transaction
     # I set ErrorAction to Stop so the Try Catch will kick in else it will just ignore. Maybe find more elegant solution to this.
     function  ArchiveAndMoveFile ($FileToMove, $PickupPath, $NewFile,$Archive,$LogSwitch) 
     {
      $LongName = $FileToMove.FullName
            Try {
                copy-Item -Path $LongName -Destination (Join-Path -Path $PickupPath -ChildPath $NewFile  ) -ErrorAction Stop 
                copy-Item -Path $LongName -Destination (Join-Path -Path $Archive -ChildPath $NewFileName  )  -ErrorAction Stop
                LogIt -Level Information -Message "Success Copied file to $NewFileName" -Id 1010 -LogIt $LogSwitch
            }
            catch{
                LogIt -Level Error -Message "Error Copy file $LongName to $PickupPath or $Archive " -Id 1110 -LogIt $LogSwitch               
            }
            Try {
                Remove-Item -Path $_.FullName   -ErrorAction Stop
                LogIt -Level Information -Message "Success Delete file  $LongName" -Id 1011 -LogIt $LogSwitch
            }
            catch  {
                LogIt -Level Error -Message "Error Deleting file  $LongName" -Id 1111 -LogIt $LogSwitch                
            }                        
     }

    # This is the rootpath of directorytree where  the files will be dropped by external system
    # Check the filepaths, Create them or throw errors depending on what is suited.
     $ExtDropPath = Join-Path -Path $RootPath -ChildPath $ExternalDropPath
     if (!(Test-Path $ExtDropPath)) {
        LogIt -Level Error -Message "The path $ExtDropPath to check for files does not exist" -Id 1100 -LogIt $DoLogIt
        Throw "The path $ExtDropPath to check for files do not exist" }
    # This is where the files will be put so internal system can pick them up
     $InterPickupPath = Join-Path -Path $RootPath -ChildPath $InternalPickupPath
     if (!(Test-Path $InterPickupPath)) {New-Item $InterPickupPath -ItemType directory}
    # This is where the files that we could move to be picked up are archived
     $HistPath = Join-Path -Path $RootPath -ChildPath $HistoryPath
     if (!(Test-Path $HistPath)) {New-Item $HistPath -ItemType directory}

     Write-Verbose "At $(Get-Date  -format 'yyyyMMddTHHmmssfffzz') Start to search in $ExtDropPath"
     Write-Verbose "for each file it finds recursively try to copy it to the  $InterPickupPath"
     Write-Verbose  "if that works copy it also to $HistPath and then delete it. Logging is $(if ($DoLogIt) {'On'} else {'Off'})"
    # ** Here is the main for each file loop. This where the action is ** # 
    Get-ChildItem -Path $ExtDropPath -Recurse -File | % { 
            # Takes the name of the parent directory - it is used in the new filename
            $System = Split-path -path $(Split-Path -path $_.Fullname -Parent) -Leaf  
            # Takes the name of the grand parent directory - it is used in the new filename
            $Organisation = Split-path -path $(Split-Path -path $(Split-Path -path $_.Fullname -Parent) -Parent )  -Leaf    
            # New file name is here decided to be part of old path with datestamp ala ISO 8601 https://en.wikipedia.org/wiki/ISO_8601 with time offset from UTC and original filename       
            $NewFileName = $("___" + $Organisation + "_" + $System + "_" + (Get-Date -Format "yyyyMMddTHHmmssfffzz" )  + "___" + $_.Name )
            #Here comes the function that does all the heavy liftening. It gives new fileName and copies to both the pickup place and the history all in one transaction
            ArchiveAndMoveFile -FileToMove $_ -PickupPath $InterPickupPath -NewFile $NewFileName -Archive $HistPath -LogSwitch $DoLogIt
    }       
        Write-Verbose "Done at $(Get-Date  -format 'yyyyMMddTHHmmssfffzz') archived files are at:"
$HistPath
  
