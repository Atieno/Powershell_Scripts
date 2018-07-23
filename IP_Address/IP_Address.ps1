
(Get-WmiObject -Class win32_networkadapterconfiguration | ?{$_.IPAddress -like '*172.24.17.177*'}).SetDNSDomain("homenet.telecomitalia.it")