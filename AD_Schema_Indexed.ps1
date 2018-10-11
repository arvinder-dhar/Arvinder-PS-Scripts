## Check if schema attributes are indexed or not 

$forest = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$Schema = $forest.schema 
$Properties = $Schema.FindAllProperties()

####Can filter more properties other than index values by running above lines of code and then typing $properties

$Properties | select Name, IsIndexed | Format-Table -AutoSize