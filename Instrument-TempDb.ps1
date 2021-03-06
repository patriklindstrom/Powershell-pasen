param (
   $sqls = 'Herkules\Dev',
    $Samples = 100,
    $IntervallSec = 10,
    $FileName = "P:\Python26\d3data\tempdb-instrument-data.csv",
    $procId=9108)

function Get-SQL-VWMemUsed{
    param([string]$Id)
    $ProcessList = Get-WmiObject Win32_Process  -Filter "Name='SQLSERVR.EXE' AND Handle=$Id"
    foreach ($Process in $ProcessList) {
        $VWMemUsed = [math]::round($Process.WorkingSetSize/1MB,1)
        $CpuUsed = [math]::round($Process.cpu,1)
        #write-host $Process.Handle "::" $Process.Name "::" ($Process.WorkingSetSize/1MB)
       }
        $VWMemUsed
    }
    
    function Get-SQL-CPUsed{
    param([string]$Id)
    $ProcessList = Get-WmiObject Win32_Process  -Filter "Name='SQLSERVR.EXE' AND Handle=$Id"
    foreach ($Process in $ProcessList) {

        $CpuUsed = [math]::round($Process.cpu,1)
        #write-host $Process.Handle "::" $Process.Name "::" ($Process.WorkingSetSize/1MB)
       }
        $CpuUsed
    }
  
    
function Get-SQLScalar {
    param([string]$SqlServer,[string]$SQlStatement)
    $cn = new-object system.data.SqlClient.SqlConnection("Data Source=$SqlServer;Integrated Security=SSPI;Initial Catalog=master");
    $cn.Open()
    $cmd = new-object "System.Data.SqlClient.SqlCommand" ($SQlStatement, $cn)
    $dr = $cmd.ExecuteScalar()
    $cn.close()
    $dr
    }
           
function Get-FileSize-TempDb {
    param([string]$S)    
    $SQlStatement = "SELECT  SUM(SIZE)/128 AS SumOfTempDBFilesMb FROM tempdb.sys.database_files;"
    $dr = Get-SQLScalar -SqlServer $S -SQlStatement $SQlStatement
    $dr
    }    
    function Get-NoOfTables-TempDb {
    param([string]$S)
    $SQlStatement = "SELECT COUNT(object_id) FROM tempdb.sys.tables;"
    $dr = Get-SQLScalar -SqlServer $S -SQlStatement $SQlStatement
    $dr
    } 

 Write-Host "date,TempDBSize,TempDBNoTbls,Cpu,Memory"  
         #   "date,TempDBSize,TempDBNoTbls,Cpu,Memory"  | Out-File   -FilePath $FileName -Encoding "ASCII"
for ($i=1; $i -le $Samples; $i++)
{ 
 Write-Host "$(Get-date -f s ),$(Get-FileSize-TempDb -S $sqls),$(Get-NoOfTables-TempDb -S $sqls),$(Get-SQL-CPUsed -Id $procId ),$(Get-SQL-VWMemUsed -Id $procId )" 
            "$(Get-date -f s ),$(Get-FileSize-TempDb -S $sqls),$(Get-NoOfTables-TempDb -S $sqls),$(Get-SQL-CPUsed -Id $procId ),$(Get-SQL-VWMemUsed -Id $procId )" |  Out-File   -FilePath $FileName -Append -Encoding "ASCII"
 Start-Sleep -s $IntervallSec  
}

    