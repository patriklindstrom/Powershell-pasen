 Write-Host Connect to Database
$cn = new-object system.data.SqlClient.SqlConnection("Data Source=Herkules\Dev;Integrated Security=SSPI;Initial Catalog=master");
$cn.Open()
Write-Host Start to create tempdb tables with random wait  processor stressubg

for ($i=1; $i -le 300; $i++)
{Write-Host Create tempdb table  $i
    $StressfulSQlStatement = "SELECT top 100000 s.name,s.type_desc  INTO #Jane_$i FROM sys.all_objects AS s CROSS JOIN sys.all_objects AS s2"
    $cmd = new-object "System.Data.SqlClient.SqlCommand" ($StressfulSQlStatement, $cn)
    $dr = $cmd.ExecuteNonQuery()
    Start-Sleep -s $(Get-Random -minimum 1 -maximum 10)
    #Add some processor 
    Write-Host Move that processor 
    for ($j=1; $j -le 1000000; $j++)
    { 
        $adder += $j
    }
    
 } 
 $cn.Close()
 Write-Host Done with tempdb and processor simulation