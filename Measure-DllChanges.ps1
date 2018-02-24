$decompiler = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.2 Tools\ildasm.exe"
$testpath = "D:\dllchangetest\Test\Serilog.Sinks.Splunk.dll"
$il = New-TemporaryFile ;$IlfileStatic = New-TemporaryFile 
[regex] $MVID = '^//\s*MVID\:\s*\{[a-zA-Z0-9\\-]+\}$' ;[regex] $baseaddress = '^//\s*Image\s+base\:\s0x[0-9A-Fa-f]*$';[regex] $timedatestamp = '^//\s*Time-date\s+stamp\:\s*0x[0-9A-Fa-f]*$'
 start-process  -filepath $decompiler  -ArgumentList ('/all', '/text',  $testpath) -RedirectStandardOutput $il.FullName -windowstyle Hidden -Wait
 (get-content $il.FullName ) -creplace $MVID,"" -creplace $baseaddress,"" -creplace $timedatestamp,"" | Out-File $IlfileStatic.FullName -Encoding ascii 
 Get-FileHash -Path  $IlfileStatic.FullName -Algorithm MD5 | select Hash
 # B2D97EDABBA8A746CBD46CC1BF8C64D1
 remove-item  $il
 remove-item $IlfileStatic
