<# 
.SYNOPSIS 
Scans a xml file and searches for xml nodes that have the same transactionid and removes them
.DESCRIPTION 
This script was written for a specific purpose to remove transaction nodes that have the same id. It takes a parameter of a file path. It uses xpath expressions to find the 
node and then xmldocument method to remove the duplicate nodes. 
.EXAMPLE 
 "c:\scripts\TinyTest.xml" | .\distinct-xml.ps1 -DistinctFileSuffix "_distinct" 
 .LINK 
latest version 
http://github.com/patriklindstrom/Powershell-pasen 
 .NOTES 
    File Name  : distinct-xml.ps1 
    Author     : Patrik Lindström  
 #> 
param  
(  
    [Parameter( 
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    [Alias('x')] 
    [Alias('file')] 
    [Alias('f')] 
    [string]$XmlFile = "c:\scripts\TinyTest.xml" , 
    [Parameter( 
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false, 
        ValueFromPipelineByPropertyName=$true) 
    ] 
    [Alias('suffix')] 
    [Alias('s')] 
    [string]$DistinctFileSuffix='_dist'     
)
[xml]$XmlContent = Get-Content $XmlFile
$XmlPath = "/File/Header/AccountList/Account/TransactionList"
$XmlSearchPath = $XmlPath + "/Transaction"
$Property = "TransactionId"
$XmlValues = @{}
$Transactions=$XmlContent.SelectNodes( $XmlPath)
$ElementKey = 0 
Foreach ($XmlElement in $Transactions.ChildNodes)
{    
    $XmlValues[$ElementKey ++]=$XmlElement.$Property   
}
 
$XmlDuplicates = @{}
Foreach ($XmlValue in $XmlValues.Values)
{
    $Items = @($XmlValues.Keys | Where { $XmlValues[$_] -eq $XmlValue})
    If ($Items.Count -gt 1)
    {
        If (!($XmlDuplicates[$Items[0]])) { $XmlDuplicates[$Items[0]] = $Items }
    }
}
Foreach ($XmlDuplicate in $XmlDuplicates.Keys)
{
    For ($i = 1; $i -lt $XmlDuplicates[$XmlDuplicate].Count; $i++)
    {
    # This is an example of a XPath search string that will be passed to SelectSingleNode not that [1] always select the first node
    # /File/Header/AccountList/Account/TransactionList/Transaction[TransactionId=17752][1]    --first
        $SearchExp = "[" + $Property +"=" + $XmlValues[$($XmlDuplicates[$XmlDuplicate][$i])] + "]"
        $XPath = $XmlSearchPath + $SearchExp + "[1]"
        $ChildToBeRemoved = $XmlContent.SelectSingleNode($XPath)
        $ChildToBeRemoved.ParentNode.RemoveChild($ChildToBeRemoved) | Out-Null
    }
}
$FileName =  (Split-Path -Path $XmlFile -Leaf)
$NewFileName= [System.IO.Path]::GetFileNameWithoutExtension($FileName) + $DistinctFileSuffix + [System.IO.Path]::GetExtension($FileName)
$NewPathFileName = (Join-Path -Path  (Split-Path -Path $XmlFile -Parent) -ChildPath $NewFileName)
$XmlContent.Save($NewPathFileName)
Write-Host "$Property duplicates found in file $XmlFile"
Foreach ($XmlDuplicate in $XmlDuplicates.Keys)
{ 
    Write-Host $Property =   $XmlValues[$($XmlDuplicates[$XmlDuplicate][1])] 
}
Write-Host "Saving Distinct File to: $NewPathFileName"