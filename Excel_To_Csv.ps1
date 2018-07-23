$ExcelWB=New-Object -ComObject excel.Application
Get-ChildItem -Path C:\Users\daniel.atieno\Desktop\GDP -Filter "*.xlsm" | ForEach-Object{
$Workbook=$ExcelWB.Workbooks.Open($_.FullName)
$newName=($_.FullName).Replace($_.Extension,".csv")
$Workbook.SaveAs($newName,6)
$Workbook.Close($false)
}