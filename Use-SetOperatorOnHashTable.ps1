$CSharpDictLinqOpLib = @"
using System.Collections;
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
        public static Dictionary<string,string> HashtableToDictionary(Hashtable table)
        {
            return table
            .Cast<DictionaryEntry>()
            .ToDictionary(kvp => kvp.Key.ToString(), kvp => kvp.Value.ToString());
        }
    }
}
"@


Add-Type -TypeDefinition $CSharpDictLinqOpLib -Language CSharp 
$testhash1 = @{"1" = "Adam"; "3"= "Cesar"; "4"= "David"};
$testhash2 = @{"1" = "Anna"; "3"= "Cesar"; "2"= "Bertil"};
$Set1 = [SetToolbox.SetOperator]::HashtableToDictionary($testhash1) 
$Set2 = [SetToolbox.SetOperator]::HashtableToDictionary($testhash2) 

Write-host "Union - What is in all the sets" -ForegroundColor Red
[SetToolbox.SetOperator]::Union($Set1,$Set2) | Format-Table 
Write-host "Except - What is the difference between the sets Set1 - Set2" -ForegroundColor Cyan
[SetToolbox.SetOperator]::Except($Set1,$Set2) |Format-Table
Write-host "Except - What is the difference between the sets Set2 - Set1" -ForegroundColor DarkCyan
[SetToolbox.SetOperator]::Except($Set2,$Set1) |Format-Table
Write-host "InterSect - What do the sets have in common" -ForegroundColor DarkMagenta
[SetToolbox.SetOperator]::InterSect($Set1,$Set2) |Format-Table

