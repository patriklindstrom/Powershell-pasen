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
    
    $XmlWriter.WriteAttributeString('VersionName', "Testbaseline")
$XmlWriter.WriteAttributeString('NameOfSystem', "HelloWorld")
$XmlWriter.WriteAttributeString('DateTime', (Get-Date -Format o))
$XmlWriter.WriteAttributeString('Source', 'wsp1064c')
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
    $WhatToCheckList = "C:\myc\BuildBinge\20150504T1531_systest\wwwroot\TCM_Client" ,
    [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    $VersionName = "TCM_7.1.5",
   [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    $NameOfSystem = "TCM",
   [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    $Source = "wsp0507c",
     [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
  $XmlPath = (join-path -path "c:\Version_Check\" -childpath ((split-path $WhatToCheckList  -leaf) + "_" + $Source + "_HashCodeTree_" + $(get-date -format "yyyyMMddTHHmmss") + ".xml")),
    
 
    
    $skipLeafPatternList = @('(?i)\.log')  ,
    $skipContainerPatternList= @('(?i)Applog|Batchconfig')
)

$regex = [regex] '\.log'
#$found = $regex.IsMatch($subject);

function hashFile($filePath,[System.Security.Cryptography.HashAlgorithm] $hashAlgo)
{  
        $file = [System.IO.File]::Open($filePath,[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
        [System.BitConverter]::ToString($hashAlgo.ComputeHash($file))
        $file.Dispose()
}
function hashStr($strToHash,[System.Security.Cryptography.HashAlgorithm] $hashAlgo)
{          

       [System.BitConverter]::ToString( $hashAlgo.ComputeHash([Char[]]$strToHash))
}

function OkItemToCheck ($node,$patternList='*')
{   $IsItOk = $TRUE
foreach ($regExp in $patternList){
     if ( $node -cmatch $regExp){
        $IsItOk = $FALSE
        break;
    }
}

$IsItOk 
}
# Recursive function that traverses throught the directories to find files and calculates checksums for them.
function CalcHash ($WhatToCheckPath, [System.Security.Cryptography.HashAlgorithm] $hashAlgo,[string]$HashValuesConcat, $XmlWriter,$skipLeafPattern,$skipContainerPattern)
{ 
    (Get-ChildItem -Path  $WhatToCheckPath   ) | % {
                $pathFromRoot = Join-Path -path  '.\' -ChildPath (join-path -path $RootDirName -ChildPath  ($_.FullName.Substring($RootPathLenght)))
                
                #Test if the item is a directory or file and test if it is in the one of the skip it reg expressions
                #if it is a file calc the hash value and go to next file or directory.
                #if it is a directory then call itself recursion and the concat the hash values and then hash it once more so the directory gets ha unique hash value for all its children.
                if (Test-path -Path $_.FullName -PathType Leaf) {  
                        if (OkItemToCheck -node $_ -patternList $skipLeafPattern )
                        {                     
                            $hashKey =  hashFile -filePath $_.FullName -hashAlgo $hashA
                            $HashValuesConcat = $HashValuesConcat + " : " + $hashKey
                            Write-host  $pathFromRoot : $hashKey
                            write-host "HashConcat:  $HashValuesConcat" 
                            $XmlWriter.WriteStartElement("File")
                                $XmlWriter.WriteAttributeString('Path',$pathFromRoot )  
                                $XmlWriter.WriteAttributeString('CreationTime',(Get-Date -Format o -date $_.CreationTime ))
                                $XmlWriter.WriteAttributeString('LastWriteTime',(Get-Date -Format o -date $_.LastWriteTime ))
                                $XmlWriter.WriteAttributeString('SizeBytes',$_.Length)  
                                $XmlWriter.WriteElementString('Name',$_.Name )                     
                                $XmlWriter.WriteElementString("HashKey",$hashKey)
                            $XmlWriter.WriteEndElement()
                        }
                    } 
                else {  
                         if (OkItemToCheck -node $_ -patternList $skipContainerPattern )
                        { 
                            $XmlWriter.WriteStartElement("Dir")
                            $XmlWriter.WriteAttributeString('Path',$_.FullName )  
                            $XmlWriter.WriteElementString('Name',$_.Name )                       
                            $WhatToCheckPath = Join-Path -Path $WhatToCheckPath -ChildPath $_.Name
                            write-host "** Dir  $WhatToCheckPath" 
                            #Here is the elegante recursive call to itself
                        $HashValuesConcat =  CalcHash -WhatToCheckPath $WhatToCheckPath  -hashAlgo $hashAlgo -HashValuesConcat $HashValuesConcat -XmlWriter $XmlWriter   -skipLeafPattern $skipLeafPattern -skipContainerPattern $skipContainerPattern
                            write-host "** Dir HashConcat:  $HashValuesConcat" 
                            $hashKey =  hashStr -strToHash $HashValuesConcat -hashAlgo $hashA
                            $XmlWriter.WriteElementString("HashKey",$hashKey)                                            
                            $HashValuesConcat = ""
                            $XmlWriter.WriteEndElement()
                            $WhatToCheckPath = Split-Path -Path $WhatToCheckPath -Parent
                        }
                }
    }
    $HashValuesConcat

}

 
# get an XMLTextWriter to create the XML
$outputPath = Split-path -path $XmlPath -Parent
if( -not (Test-Path -Path $outputPath)){
    New-Item -ItemType Directory -Path $outputPath
}
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
$XmlWriter.WriteAttributeString('VersionName', $VersionName)
$XmlWriter.WriteAttributeString('NameOfSystem', $NameOfSystem)
$XmlWriter.WriteAttributeString('DateTime', (Get-Date -Format o))
$XmlWriter.WriteAttributeString('Source', $Source)
 

$hashA = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
#$sha1 = new-object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
$RootPathLenght  = $WhatToCheckList.Length
$RootDirName = Split-Path -path $WhatToCheckList -Leaf
$XmlWriter.WriteComment("Normal search for files in $RootDirName - no filters")
$XmlWriter.WriteStartElement("ARootDir")
$XmlWriter.WriteAttributeString('HashAlgoritm',$hashA.ToString())
$XmlWriter.WriteAttributeString('Filter',"NoFilter")
$XmlWriter.WriteAttributeString('Path',$WhatToCheckList )  
$XmlWriter.WriteElementString('Name',$RootDirName )  
[string] $HashValuesConcat = ""
# Recursive function that calculates hashvalues for files 
$HashValuesConcat = CalcHash  -WhatToCheckPath $WhatToCheckList  -hashAlgo $hashA -HashValuesConcat $HashValuesConcat -XmlWriter $XmlWriter  -skipLeafPattern $skipLeafPatternList -skipContainerPattern $skipContainerPatternList    

$XmlWriter.WriteEndElement()
$XmlWriter.WriteEndElement()
$XmlWriter.WriteEndDocument()
$XmlWriter.Flush()
$XmlWriter.Close()

$XmlPath