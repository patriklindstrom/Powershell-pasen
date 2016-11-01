$CSharpDictLinqOpLib = @"
using System.Collections.Generic;
using System.Linq;
namespace SetToolbox
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

$Set1 =   New-Object "System.Collections.Generic.Dictionary[string,string]"
$Set2 =   New-Object "System.Collections.Generic.Dictionary[string,string]"

$Set1.Add(1,"Adam")
$Set1.Add(3,"Caesar")
$Set1.Add(4,"David")
$Set2.Add(1,"Adam")
$Set2.Add(3,"Caesar")
$Set2.Add(2,"Bertil")
Add-Type -TypeDefinition $CSharpDictLinqOpLib -Language CSharp 
Write-host "Union - What is in all the sets" -ForegroundColor Red
[SetToolbox.SetOperator]::Union($Set1,$Set2) | Format-Table 
Write-host "Except - What is the difference between the sets" -ForegroundColor Cyan
[SetToolbox.SetOperator]::Except($Set1,$Set2) |Format-Table
Write-host "InterSect - What do the sets have in common" -ForegroundColor DarkMagenta
[SetToolbox.SetOperator]::InterSect($Set1,$Set2) |Format-Table