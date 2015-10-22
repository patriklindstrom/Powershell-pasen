# http://www.powershellmagazine.com/2013/08/19/mastering-everyday-xml-tasks-in-powershell/
[xml]$MotherXml =  Get-Content "C:\myc\CompareTent\CoisFakeFactory\MeFake_Template.xml"
Get-ChildItem -Path "C:\myc\CompareTent\CoisFakeFactory\Data2" | % {
        $SmallXml = New-Object -TypeName XML
        $SmallXml.Load($_.FullName)
        ForEach ($XmlNode in $SmallXml.DocumentElement.Header.AccountList.ChildNodes) {
            $MotherXml.DocumentElement.Header.AccountList.AppendChild($MotherXml.ImportNode($XmlNode, $true))
            $MotherXml.DocumentElement.Header.AccountList.AppendChild($MotherXml.ImportNode($XmlNode, $true))
            $MotherXml.DocumentElement.Header.AccountList.AppendChild($MotherXml.ImportNode($XmlNode, $true))
            $MotherXml.DocumentElement.Header.AccountList.AppendChild($MotherXml.ImportNode($XmlNode, $true))
        }
        $SmallXml = $null
    }
$MotherXml.Save("C:\myc\CompareTent\CoisFakeFactory\MeFake.xml")  
