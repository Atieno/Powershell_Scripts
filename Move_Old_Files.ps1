#---define parameters
#---get Current Date
$Now=Get-Date
$Days="60"
$SorceFolder="C:\Users\daniel.atieno\Desktop\CallerTable\Production\CallerTable"
$DestFolder="C:\Backup\CallerTable"

#-Copy-Item -Path $SorceFolder -Destination $DestFolder -Recurse -Force
#--- define extension
$Extension="*.xls"

#--- Define last writetime parameter based on days 
$LastWrite=$Now.AddDays(-$Days)

#--Get the files with retention capacity more than 60 days and move them
Get-ChildItem -Path $SorceFolder | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-60)} |
Move-Item -Destination $DestFolder  

Write-Output "The Old Files being moved" {Write-Host $_ -ForegroundColor Green}
