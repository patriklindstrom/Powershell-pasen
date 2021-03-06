<# 
.SYNOPSIS 
Moves Applog files to archive. 
.DESCRIPTION 
It looks for Hardcoded RootPath after childdirectories that have a child directory named Applogs. 
It then uses robocopy to move directory for several websites to archive directory named with timestamp and directory name.
.EXAMPLE 
 Simple run .\Archive-AppLogs.ps1 
.EXAMPLE 
Pipe directory "C:\inetpub"|.\Archive-AppLogs.ps1  
.EXAMPLE 
Stop all websites on local IIS with iisreset -stop then starts them afterward. This is so no logfiles are locked.  .\Archive-AppLogs.ps1  -Force 1
.EXAMPLE 
Directory as parameter and other Relative Archiveapplogpath. Send it to  script eg compression: .\Archive-AppLogs.ps1  -ArchiveDir "Applog\testcase1\" | zip-dir
.PARAMETER RootPath 
Path to where to start looking for subdirectories that has subdir with Applog. Default is D:\inetpub\wwwroot. Alias is path.
.PARAMETER ArchivePath 
Path to where to start looking for subdirectories that has subdir with Applog. Default is ArchiveAppLog. Alias is path.
.PARAMETER OutPut 
Path to where all the logfiles where moved
.LINK 
Robocopy help 
http://ss64.com/nt/robocopy.html
.LINK 
Latest version 
http://github.com/patriklindstrom/Powershell-pasen
.NOTES 
    File Name  : Archive-AppLogs.ps1 
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
    [Alias('p')] 
    [string]$RootPath='D:\inetpub\wwwroot' ,
    [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('a')] 
    [string]$ArchiveDir='ArchiveAppLog',
        [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('f')] 
    [boolean]$Force = 0
    )
 if ($Force -eq $TRUE){
    iisreset -stop
 }
$TimeStamp = Get-Date -format yyyyMMddTHHmm
Push-Location
Set-Location $RootPath
Get-ChildItem | ?{ $_.PSIsContainer } | ?{$_ | Get-ChildItem -Filter Applog} | foreach { 
    $SourcePath = Join-Path -Path $_.FullName -ChildPath Applog
    $DestDir = $_.FullName | split-path -leaf
    $DestPath = Join-Path -Path $RootPath -ChildPath $ArchiveDir\$TimeStamp\$DestDir
    robocopy $SourcePath $DestPath /MOV
     
 }
 if ($Force -eq $TRUE){
    iisreset -start
    }
    Pop-Location
    $DestPath | split-path