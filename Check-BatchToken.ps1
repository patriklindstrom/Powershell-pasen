param (
   $outputPath = 'D:\TietoFTP\Export\ChuckYeager',
    $CleanUpTimeOut = 100
    )    
    Start-Sleep -Milliseconds $(Get-Random -minimum 1 -maximum 2000)
    $token =  $ComputerInfo.Name +'_'+ $(Split-Path -Parent  $myinvocation.mycommand.path | Split-Path -leaf)
    $NewTokenPath =  Join-Path -path $outputPath -ChildPath $token
    if( Test-Path $NewTokenPath)
    {
        if ($(Get-Item  $NewTokenPath).LastWriteTime -lt $((get-date).addseconds(-$CleanUpTimeOut)))
        { 
             "Clean up seems stale token"
             Remove-Item $NewTokenPath
        }
    }
    else
        { 
         "Set a directory as token"
            New-Item $outputPath\$token -type directory
        }