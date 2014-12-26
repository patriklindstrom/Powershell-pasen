<# 
.SYNOPSIS 
Scans a directory and calculated hash values for files. So directory structures can easily be compared
.DESCRIPTION 
Uses hash algoritm and calculates hash values. These are stored in xml tree that represent directory structue. Filt for exclude and include can be given.. 
.EXAMPLE 
 "c:\deploypackage" | .\VersionCheck-Deploy.ps1 
 .LINK 
latest version 
http://github.com/patriklindstrom/Powershell-pasen 
 .NOTES 
    File Name  : VersionCheck-Deploy.ps1 
    Author     : Patrik Lindström  
 #> 
param  
(  
    [Parameter( 
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    [Alias('l')] 
    [Alias('file')] 
    $WhatToCheckList = "D:\Users\Patrik\Documents\GitHub\Powershell-pasen\pstestfiles\VersionCheck-Deploy-Test\" ,
     [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    $XmlPath = "$env:temp\HashCodeTree.xml"   
)

function hashIt($filePath ,[System.Security.Cryptography.HashAlgorithm] $hashAlgo)
{ 
    $file = [System.IO.File]::Open($filePath,[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
    [System.BitConverter]::ToString($hashAlgo.ComputeHash($file))
    $file.Dispose()
}


 
# get an XMLTextWriter to create the XML
$XmlWriter = New-Object System.XMl.XmlTextWriter($XmlPath,$Null)
 
# choose a pretty formatting:
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 1
$XmlWriter.IndentChar = "`t"
 
# write the header
$xmlWriter.WriteStartDocument()
 
# set XSL statements
$xmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")
 
# create root element "machines" and add some attributes to it
$XmlWriter.WriteComment('List of machines')
$xmlWriter.WriteStartElement('Machines')
$XmlWriter.WriteAttributeString('current', $true)
$XmlWriter.WriteAttributeString('manager', 'Tobias')
 

$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
#$sha1 = new-object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
$RootPathLenght  = $WhatToCheckList.Length
$RootDirName = Split-Path -path $WhatToCheckList -Leaf
(Get-ChildItem -Path  $WhatToCheckList -Recurse ) | % {
                $pathFromRoot = Join-Path -path  '.\' -ChildPath (join-path -path $RootDirName -ChildPath  ($_.FullName.Substring($RootPathLenght)))
                if (Test-path -Path $_.FullName -PathType Leaf) {                        
                        $hashKey = hashIt $_.FullName -hashAlgo $md5
                        Write-host  $pathFromRoot : $hashKey

                    } 
                else {  Write-host "** Dir  $pathFromRoot" }
    }

