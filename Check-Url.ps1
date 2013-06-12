#$url = "http://mysite.appharbor.com"
$url = "http://www.lcube.se"
[net.WebClient]  $webclient = new-object net.WebClient
$webclient.Encoding=[text.encoding]::ascii
$startTime = [system.DateTime]::Now 
$rawWeb = $webclient.downloadData($url)
$stopTime = [system.DateTime]::Now 
$encodedText = [text.encoding]::ascii 
$webText = $encodedText.getString($rawWeb)
$DiffTime = $stopTime - $startTime 
return ($webText,$DiffTime.TotalSeconds)
#$webText