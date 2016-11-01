$CSharpLinqMojo = @"
using System.Collections.Generic;
using System.Linq;
namespace CompareTool
{
    public class DictCompareOnKeyOnly : IEqualityComparer<KeyValuePair<string, string>>
    {
        public bool Equals(KeyValuePair<string, string> x, KeyValuePair<string, string> y)
        {
            return x.Key.Equals(y.Key);
        }
        public int GetHashCode(KeyValuePair<string, string> obj)
        {
            return obj.Key.GetHashCode();
        }
    }
    public static class SetOperator
    {
        static public Dictionary<string, string> Union(Dictionary<string, string> setA, Dictionary<string, string> setB  )
        { 
           return setA.Union(setB, new DictCompareOnKeyOnly()).ToDictionary(ld => ld.Key, ld => ld.Value); ;          
        }
        static public Dictionary<string, string> Except(Dictionary<string, string> setA, Dictionary<string, string> setB)
        {
            return setA.Except(setB, new DictCompareOnKeyOnly()).ToDictionary(ld => ld.Key, ld => ld.Value); ;
        }
        static public Dictionary<string, string> InterSect(Dictionary<string, string> setA, Dictionary<string, string> setB)
        {
            return setA.Intersect(setB, new DictCompareOnKeyOnly()).ToDictionary(ld => ld.Key, ld => ld.Value); ;
        }
    }
}
"@
function ConvertTo-Dictionary
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [hashtable]
        $InputObject,
        [Type]
        $KeyType = [string]
    )
    process
    {
        $outputObject = New-Object "System.Collections.Generic.Dictionary[[$($KeyType.FullName)],[$($KeyType.FullName)]]"
        foreach ($entry in $InputObject.GetEnumerator())
        {
            $newKey = $entry.Key -as $KeyType           
            if ($null -eq $newKey)
            {
                throw 'Could not convert key "{0}" of type "{1}" to type "{2}"' -f
                      $entry.Key,
                      $entry.Key.GetType().FullName,
                      $KeyType.FullName
            }
            elseif ($outputObject.ContainsKey($newKey))
            {
                throw "Duplicate key `"$newKey`" detected in input object."
            }
            $outputObject.Add($newKey, $entry.Value)
        }
        Write-Output $outputObject
    }
}
 
Add-Type -TypeDefinition $CSharpLinqMojo -Language CSharp 
$testhash1 = @{"1" = "Adam"; "3"= "Cesar"; "4"= "David"};
$testhash2 = @{"1" = "Anna"; "3"= "Cesar"; "2"= "Bertil"};
$testdict1 = ConvertTo-Dictionary $testhash1
$testdict2 = ConvertTo-Dictionary $testhash2
$resultDict_Union = [CompareTool.SetOperator]::Union($testdict1,$testdict2)
Write-host "Union" -ForegroundColor Red
$resultDict_Union |Format-List 
$resultDict_Except = [CompareTool.SetOperator]::Except($testdict1,$testdict2)
Write-host "Except" -ForegroundColor Cyan
$resultDict_Except |Format-List
$resultDict_InterSect = [CompareTool.SetOperator]::InterSect($testdict1,$testdict2)
Write-host "InterSect" -ForegroundColor DarkMagenta
$resultDict_InterSect |Format-List