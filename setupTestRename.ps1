# Setup test data for Rename-Msg

param  
(  
    [Parameter( 
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true
    ) 
    ] 
    [Alias('d')] 
    [string]$RootPath='C:\myc\BuildBinge\Ahl\Gossips' )

$DateString
[string] $DateString = Get-Date  -format '"yyyyMMddTHHmmssfffzz"'

Write-Host "Set up nonsens testdata in folder structure from ReName-Msg script at root path $RootPath "
Write-Host 'Folder structure is $\data\System\Organisation\FileName'
New-Item (join-path $RootPath -ChildPath '\data\ZEBA\Conversation\Qwerty123.txt')  -type file -force -value `
    $("I was a Qwerty123.txt; but now I will become: ___ZEBA___Conversation___" + $DateString + "___Qwerty123.tx")
New-Item (join-path $RootPath -ChildPath '\data\ZEBA\Ticket\Asdf123.txt') -type file -force -value `
    $("I was a Asdf123.txt; but now I will become: ___ZEBA___Conversation___" + $DateString + "__Asdf123.txt")
New-Item (join-path $RootPath -ChildPath '\data\ZEBI\Conversation\Juyppp321.txt')  -type file -force  -value `
    $("I was a Juyppp321.txt; but now I will become: ___ZEBI___Conversation___" + $DateString + "Juyppp321.txt")
New-Item (join-path $RootPath -ChildPath '\data\ZEBI\Ticket\Khwhe552.txt') -type file -force -value `
    $("I was a Khwhe552.txt; but now I will become: ___ZEBI___Conversation___" + $DateString + "Khwhe552.txt")
New-Item (join-path $RootPath -ChildPath '\data\ZEBS\Conversation\Lkj762.txt') -type file -force -value `
    $("I was a Lkj762.txt; but now I will become: ___ZEBS___Conversation___" + $DateString + "Lkj762.txt")
New-Item (join-path $RootPath -ChildPath '\data\ZEBS\Ticket\Xskx881.txt') -type file -force -value `
    $("I was a Xskx881.txt; but now I will become: ___ZEBS___Conversation___" + $DateString + "Xskx881.txt")

$RootPath