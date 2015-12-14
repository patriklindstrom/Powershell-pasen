 <#
.SYNOPSIS
Script to scan the TCM DB installation skript logfiles to find errors. 
.DESCRIPTION
The problem is that most of the logfiles contains information about statements that are ok and did not contain any error so lines that talks about change database context, 
or how many rows are affected needs to be filtered out. So this script scan all *.txt files in directory shows all lines that does not contain OkWords eg: database context or rows saffected, 
since these are normal output that do not indicate errors. All blank lines are also skipped
.PARAMETER InputDir
The directory where the logfiles are . Eg C:\TCM\install\result\XYZserver.  Can also be piped into the script. Default value is  C:\TCM\install\result\$env:computername
it searches for file recursively. 
.PARAMETER Outputfile
The File where the result is put with as a csv file with columns:  FileName,Linenumber,Message
.PARAMETER regexFilterOkWord
This a regular expressions that list the word that indicates that this logline do not contain errors. It is defaulted to:
'(\W|^)(database\scontext|rows\saffected|maximum\skey\slength)(\W|$)' 
Which means a match is beginning of line or wordsepartor char then list of words sep with pipe char - \s means space - then word separator or end of line.
.EXAMPLE
Simple default will look in c:\tcm
 .\Debug-TCMInstall.ps1 
.EXAMPLE
"C:\TCM\install\result\XYZserver" | .\Debug-TCMInstall.ps1 -outputfile c:\tcm\TCMInstall_Report.csv
.LINK
latest version
http://github.com/patriklindstrom/Powershell-pasen
.LINK
About Author and script
http://www.lcube.se
.NOTES
    File Name  : Debug-TCMInstall.ps1 
    Author     : Patrik Lindstrom LCube
you need the Replace-TextElement.ps1 see https://github/patriklindstrom/powershell-pasen for latest version 
#>
param  
(  
    [Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
     $InputDir = "C:\TCM\install\result\$env:computername" ,
    [Parameter(
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$true)
    ]
     $OutputFile = "$(split-path $InputDir -parent)\TCMInstall_Report.csv",
       [Parameter(
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$true)
    ]$regexFilterOkWord = [regex] '(\W|^)(database\scontext|rows\saffected|maximum\skey\slength|-----)(\W|$)' ) 
    # if output file directory does not exist create one.
    if (!(Test-path ($OutputFile | Split-Path -Parent)  -PathType Container )) {  New-Item  ( $OutputFile | Split-Path -Parent) -type directory}
    "FileName,Linenumber,Message"  | set-content -path  $OutputFile -Encoding Unicode
    Write-Verbose "Scanning directory $InputDir "
    $InputDir  | Get-ChildItem -Recurse  -Include *.txt | % { 
                  $i=0
                  Write-Verbose   "** Scanning in file  $_"                     
                  foreach ($line in get-content $_) {
                        $i=$i+1 
                        #  Check that there is No match of Ok word or that line is not empty   
                        $line=$line.TrimEnd()                    
                        if (!($regexFilterOkWord.Match($line).Success -or $line.Length -eq 0)) {
                            "{0},{1},{2}" -f """$_""",$i,"""$line""" | add-content -path  $OutputFile -Encoding Unicode
                            Write-Verbose  "$_,$i,$line" 
                        }
                   }                  
               }
