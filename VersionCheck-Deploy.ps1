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
    $XmlPath = "$env:temp\HashCodeTree2.xml"   
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
$XmlWriter.WriteComment('List of directories and their unique hashcode')
$xmlWriter.WriteStartElement('CheckedRoots')
$XmlWriter.WriteAttributeString('VersionName', "Testbaseline")
$XmlWriter.WriteAttributeString('NameOfSystem', "HelloWorld")
$XmlWriter.WriteAttributeString('DateTime', (Get-Date -Format o))
$XmlWriter.WriteAttributeString('Source', 'TestBenchServer')
 

$hashA = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
#$sha1 = new-object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
$RootPathLenght  = $WhatToCheckList.Length
$RootDirName = Split-Path -path $WhatToCheckList -Leaf
$XmlWriter.WriteComment("Normal search for files in $RootDirName - no filters")
$XmlWriter.WriteStartElement("ARootDir")
$XmlWriter.WriteAttributeString("RootDirName","$RootDirName")
$XmlWriter.WriteAttributeString('HashAlgoritm',$hashA.ToString())
(Get-ChildItem -Path  $WhatToCheckList  ) | % {
                $pathFromRoot = Join-Path -path  '.\' -ChildPath (join-path -path $RootDirName -ChildPath  ($_.FullName.Substring($RootPathLenght)))
                if (Test-path -Path $_.FullName -PathType Leaf) {                        
                        $hashKey = hashIt $_.FullName -hashAlgo $hashA
                        Write-host  $pathFromRoot : $hashKey
                        $XmlWriter.WriteStartElement("File")
                            $XmlWriter.WriteAttributeString('CreationTimeUtc',$_.CreationTimeUtc )
                            $XmlWriter.WriteAttributeString('LastWriteTime',$_.LastWriteTime)
                            $XmlWriter.WriteAttributeString('Size',$_.Length)  
                            $XmlWriter.WriteElementString('Name',$_.Name )                     
                            $XmlWriter.WriteElementString("HashKey",$hashKey)
                        $XmlWriter.WriteEndElement
                    } 
                else {  Write-host "** Dir  $pathFromRoot" 
                        $XmlWriter.WriteStartElement("Dir")
                            $XmlWriter.WriteElementString('Name',$_.Name )                    
                        $XmlWriter.WriteEndElement
                }
    }
     $XmlWriter.WriteEndElement
$XmlWriter.WriteEndElement
$XmlWriter.WriteEndDocument()
$XmlWriter.Flush()
$XmlWriter.Close()

