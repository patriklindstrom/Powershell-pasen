SELECT  SUM(SIZE)/128 AS SumOfTempDBFilesMb
FROM tempdb.sys.database_files;

Get-WmiObject Win32_Computersystem
# Get-WmiObject -namespace "root\cimv2" -List
# Get-Counter -ListSet * | sort CounterSetName | select CounterSetName –Unique

# Get-Counter -Counter "\Processorinformation(_Total)\Ledig tid i procent" -MaxSamples 100
#Get-Counter -ListSet Processorinformation | select -ExpandProperty PathsWithInstances 
#Get-Counter -Counter "\Processorinformation(_Total)\Ledig tid i procent" -MaxSamples 100

#Get-Counter -Counter "\Processor(_Total)\% Processor Time" , "\Memory\Available Bytes" -MaxSamples 10


Get-WmiObject Win32_Computersystem

Get-WmiObject -Class Win32_processor -List

Get-WmiObject -Class  win32_service -filter "name like 'sql%'" | select name 
gwmi win32_process -filter "name like 'sql%'" | select  name,ID



gwmi win32_process -filter "pid = 2568" | format-table





$proc = get-wmiobject Win32_PerfFormattedData_PerfProc_Process
$proc


 | ? { $_.name -eq 'sqlservr' } 
| select name,  PercentProcessorTime

$foo = gwmi -class Win32_PerfFormattedData_PerfProc_Process -List
$foo |Format-Table
gwmi -class Win32_PerfRawData_PerfProc_Process -List
 
 $theProcess = Get-WmiObject win32_process -Filter "name like '%sql%'" | select name
 
 $components = @("COMP_Number1","COMP_Number2")
$theProcess | %{ 
    $p = $_
    $running = $components | ?{$p.commandline -match $_}
    $notrunning = $components | ?{ $running -notcontains $_ }
}

$notrunning
    $ProcessList = Get-WmiObject Win32_Process  -Filter "Name='SQLSERVR.EXE' AND PID=8720"
    function GetSQLServPerf {
    param([string]$Srver)
    $ProcessList = Get-WmiObject Win32_Process  -Filter "ID=8720"
    foreach ($Process in $ProcessList) {
        $VWMemUsed = [math]::round($Process.WorkingSetSize/1MB,1)
        #$CpuUsed = [math]::round($Process.cpu,1)
        #write-host $Process.Handle "::" $Process.Name "::" ($Process.WorkingSetSize/1MB)
       }
         $VWMemUsed #$CpuUsed
    }
    
    GetSQLServPerf


function Get-SQLServPerf {
    param([string]$Srver)
    $ProcessList = Get-WmiObject Win32_Process  -Filter "Name='SQLSERVR.EXE' AND Handle=8720"
    foreach ($Process in $ProcessList) {
        $VWMemUsed = [math]::round($Process.WorkingSetSize/1MB,1)
        $CpuUsed = [math]::round($Process.cpu,1)
        #write-host $Process.Handle "::" $Process.Name "::" ($Process.WorkingSetSize/1MB)
       }
        $(Get-date -f hh:m:s ), $VWMemUsed, $CpuUsed
    }
       
function Get-FileSize-TempDb {
    param([string]$Srver)
    $cn = new-object system.data.SqlClient.SqlConnection("Data Source=$Srver;Integrated Security=SSPI;Initial Catalog=master");
    $cn.Open()
    $SQlStatement = "SELECT  SUM(SIZE)/128 AS SumOfTempDBFilesMb FROM tempdb.sys.database_files;"
    $cmd = new-object "System.Data.SqlClient.SqlCommand" ($SQlStatement, $cn)
    $dr = $cmd.ExecuteScalar()
    $dr
    }    
    function Get-NoOfTables-TempDb {
    param([string]$Srver)
    $cn = new-object system.data.SqlClient.SqlConnection("Data Source=$Srver;Integrated Security=SSPI;Initial Catalog=master");
    $cn.Open()
    $SQlStatement = "SELECT COUNT(object_id) FROM tempdb.sys.tables;"
    $cmd = new-object "System.Data.SqlClient.SqlCommand" ($SQlStatement, $cn)
    $dr = $cmd.ExecuteScalar()
    $dr
    }    
    
    

    Get-FileSize-TempDb -Srver 'Herkules\Dev'
    Get-NoOfTables-TempDb 'Herkules\Dev'
    GetSQLServPerf  
    
    $FreeMem=(get-wmiobject win32_perfrawdata_perfos_memory).AvailableMBytes 
    
    $FreeMem 
    
    