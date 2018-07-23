Get-WmiObject Win32_LogicalDisk -filter -computer (Get-Content .\Servers.txt) | 
Select SystemName,DeviceID,VolumeName,@{Name="Size(GB)";Expression={"{0:N1}" 
-f($_.size/1gb)}},@{Name="FreeSpace(GB)";Expression={"{0:N1}" -f($_.freespace/1gb)}} | Out-GridView