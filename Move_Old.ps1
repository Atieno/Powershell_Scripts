#---define parameters
#---get Current Date
$Now=Get-Date
$Days="365"
$SorceFolder = "C:\Users\daniel.atieno\Desktop\CallerTable\Production\CallerTableNew"
$DestFolder = "C:\Backup\CallerTable\CallerTable_New"

#-Copy-Item -Path $SorceFolder -Destination $DestFolder -Recurse -Force
#--- define extension
$Extension="*.xls"

#--- Define last writetime parameter based on days 
$LastWrite=$Now.AddDays(-$Days)

foreach ($file in (Get-ChildItem $SorceFolder)) {
    if($file.$LastWriteTime -gt $Days){
        #--- test to see if the file already exists in the destination. If not=> Move/copy
        if(!(Test-path (Join-Path $DestFolder $file.name)))
        {
        Move-Item  -Destination $DestFolder
    }
    }
    
}
