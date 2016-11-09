
# http http://swapi.co/api/people
#  (Invoke-RestMethod -Uri 'http://swapi.co/api/people/1' -Method Get)   

$starWarsCrew = Invoke-WebRequest -Uri 'http://swapi.co/api/people' -Method Get -usebasicparsing |  ConvertFrom-Json

#foreach ($foo in $webRespons2)  {  $foo.ToString()}
# key, name, height, birthyear

$crewCount = $starWarsCrew.count
$starWarsCrewData =  [System.Collections.ArrayList]@()

for($i=1; $i -le $crewCount; $i++)
{ $crewmember = (Invoke-WebRequest -Uri "http://swapi.co/api/people/$i" -Method Get -usebasicparsing |  ConvertFrom-Json | Select-Object -Property Name,height, birth_year)
   $starWarsCrewData.Add( $crewmember)
}

for($i=1; $i -le 1000; $i++)
{   $crewmemberNr= (Get-Random -minimum 0 -maximum $starWarsCrewData.Count)
    $transaction = (Get-Random -minimum -25964951 -maximum 25964951)
   $oldTrans="$([guid]::NewGuid()),$($starWarsCrewData[$crewmemberNr].name),$($starWarsCrewData[ $crewmemberNr ].Height,$((Get-Random -minimum -25964951 -maximum 25964951)))"

   If ((Get-Random -minimum 0 -maximum 100) -le 10) 
   { $crewmemberNr= (Get-Random -minimum 0 -maximum $starWarsCrewData.Count)
     $transaction = (Get-Random -minimum -25964951 -maximum 25964951)
     Write-Host "Write only Old one file to both files" -BackgroundColor DarkBlue
     $newTrans="$([guid]::NewGuid()),$($starWarsCrewData[$crewmemberNr].name),$($starWarsCrewData[ $crewmemberNr ].Height,$((Get-Random -minimum -25964951 -maximum 25964951)))"
     
   }
   else { Write-Host "Write Old one and new on to file" -BackgroundColor DarkRed}
}