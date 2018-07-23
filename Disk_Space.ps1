$DiskSizeReport = @()
$computers = "DEBEN9010DB001P", "DEBEN9010DB002P", "DEBEN9010DB003P", "DEBEN9010DB006P"
$computers | ForEach {
$Disks = Get-WmiObject win32_logicaldisk -ComputerName $_ -Filter "Drivetype=3" -ErrorAction SilentlyContinue |
Select-Object @{Label = "Server Name";Expression = {$_.SystemName}},
@{Label = "Drive Letter";Expression = {$_.DeviceID}},@{Label = "Total Capacity (GB)";Expression = {"{0:N1}" -f( $_.Size / 1GB)}},
@{Label = "Used Space (GB)";Expression = {(Round($_.Size /1GB,2)) - (Round($_.FreeSpace /1GB,2))}},
@{Label = "Free Space (GB)";Expression = {"{0:N1}" -f( $_.Freespace / 1GB ) }},@{Label = "Free Space (%)"; Expression = {"{0:P0}" -f ($_.freespace/$_.size) }}
$DiskSizeReport += $Disks
} 
$DiskSizeReport | Export-CSV "C:\\DiskSizeReport.csv" -NoTypeInformation -Encoding UTF8