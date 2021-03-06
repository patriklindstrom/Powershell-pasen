<# 
.SYNOPSIS 
Create Share for Applog files directory so developers can read applogs. 
.DESCRIPTION 
It looks for Hardcoded RootPath after childdirectories that have a child directory named Applogs. 
It then uses commands from opensource carbon module http://get-carbon.org/ to publish  directories for several websites and grant rights to them
.EXAMPLE 
 Simple run .\Create-AppLogsShare.ps1 DeveloperADGroup
.EXAMPLE 
Pipe directory  DeveloperADGroup |.\Create-AppLogsShare.ps1  
.EXAMPLE 
Pipe directory parameter for prefix of Sharename and make the shared directories invisible DeveloperADGroup |.\Create-AppLogsShare.ps1  -Invisible $TRUE -SharePrefix SKYNET_

.EXAMPLE 
Directory as parameter and other Relative Archiveapplogpath. Send it to  script eg compression: .\Create-AppLogsShare.ps1  -ArchiveDir "Applog\testcase1\" | zip-dir
.PARAMETER RootPath 
Path to where to start looking for subdirectories that has subdir with Applog. Default is D:\inetpub\wwwroot. Alias is path.
.PARAMETER ShareRootPath 
Path to where to start looking for subdirectories that has subdir with Applog. Default is D:\inetpub\wwwroot. Alias is path.

.PARAMETER OutPut 
Array of share names
.LINK 
Carbon Module required
http://get-carbon.org/

.LINK 
Latest version 
http://github.com/patriklindstrom/Powershell-pasen
.NOTES 
    File Name  : Create-AppLogsShare.ps1 
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
    [string]$ADGroup='RG-GLOBALF-READ',
        [Parameter( 
        Position=2, 
        Mandatory=$false, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('i')] 
    [boolean]$Invisible = $FALSE,
    [Parameter( 
        Position=3, 
        Mandatory=$false, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true
        ) 
    ] 
    [Alias('pre')] 
    [string]$SharePrefix=''
    )

function ComputeShareName([string]$orgName,[boolean]$inv,[string]$pre)
{   [string]$InvShareToken = '';
    if ($inv){$InvShareToken='$'}
    [string]  $newShareName= $pre + $orgName + $InvShareToken;
    return $newShareName;
}

Push-Location
Set-Location $RootPath
$ShareArr = @()
Get-ChildItem | ?{ $_.PSIsContainer } | ?{$_ | Get-ChildItem -Filter Applog} | foreach { 
    $SourcePath = Join-Path -Path $_.FullName -ChildPath Applog
    $ShareName = $(ComputeShareName $_.Name $Invisible $SharePrefix )
    Install-SmbShare -Name $ShareName -Path $SourcePath  -ReadAccess $ADGroup -Description "Read Access to IIS Applog files for Developers"
    Grant-Permission -Identity $ADGroup -Permission Read -Path $SourcePath   
    $ShareArr += $ShareName
 }
Pop-Location
$ShareArr
