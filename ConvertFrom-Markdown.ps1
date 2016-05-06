<#
SYNOPSIS
Converts on or many Markdown textfiles to html. Uses githubs restservice.
.DESCRIPTION
All files  ending with .txt or md1 or md will recursivly be run against githubs restservice api.github.com/markdown. Default is that it will be put in same directory with htm as extension.
.EXAMPLE
 runs .\ConvertFrom-Markdown.ps1 -FilePath readme.md
.EXAMPLE
Pipe directory "C:\projdocumentation" | .\ConvertFrom-Markdown.ps1  -OutputPath "c:\projdoc_html"
.EXAMPLE
Directory as parameter .\run-sql.ps1 -SqlDir "T:\testSql\"
 
.PARAMETER FilePath
The name of the sql server that the scripts should be run on. If you have an instance name just use "BigSqlServer\InstansName". Has alias server and s.
Note that default is localhost. So if you forget to give this parameter but mean to run it on another server you could get suprised or very sad.
 
.PARAMETER OutputPath
This is where the output from the sql scripts get saved. If it does not exist it creates an output folder in the root of the SQLDir
 
.LINK
latest version
http://github.com/patriklindstrom/Powershell-pasen
.LINK
Documentation for Github api
https://developer.github.com/v3/markdown/
.LINK
About Invoke-RestMethod
https://technet.microsoft.com/en-us/library/hh849971.aspx
.LINK
About Author and script
http://www.lcube.se
.NOTES
    File Name  : ConvertFrom-Markdown.ps1
    Author     : Patrik Lindström LCube
    Requires   : PowerShell V3
You must have internet access for this to work. Also Github has a limit of 60 req per hour.If you need more then you have to register.
 
#>
param 
( 
    [Parameter(
        Position=0,
        Mandatory=$false,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('file')]
    [Alias('f')]
    [string]$FilePath='C:\myc\github\Powershell-pasen\pstestfiles\ConvertFrom-MarkDown-Test\Example2.md1' ,    
    [Parameter(
        Position=1,
        Mandatory=$false,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('o')]
    [string]$OutputPath
)
 
if (!$OutputPath)
{
    $OutputPath= (Split-Path -Path $FilePath -Parent)
}
$ApiUri = "https://api.github.com/markdown"
$NewFilePath = [System.IO.Path]::ChangeExtension( (Join-Path -Path $OutputPath -childPath (Split-Path -Path $FilePath -Leaf )),'html')
$body = @{   
    #text =  [System.IO.File]::ReadAllText($FilePath,[System.Text.Encoding]::GetEncoding("utf-8"))
    text = (Get-Content $FilePath -Raw -Encoding UTF8).ToString() 
    mode = "markdown"
}
(Invoke-RestMethod -Method Post -Uri $ApiUri  -Body ($body |Convertto-json)  -ContentType 'application/json; charset=utf-8' )| Out-File $NewFilePath -Encoding utf8

 