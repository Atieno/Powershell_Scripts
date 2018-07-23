# Store result of an array and then pass along a pipeline to Select-String:
$result=ipconfig
$result | Select-String "Address"
#Find the number of elements stored in an Array
$result.Count
#Find the 2nd element
$result[1]
#find if an element is an array
$dir_result=Dir
$dir_result -is [array]
$dir_result.Count

#Access the 5th element 
$dir_result[4] | Format-List *