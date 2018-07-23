$computers | foreach ($computer = $_) {  

    try {
        $os=Get-WmiObject win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        #continue if no errors are captured
        Get-WmiObject Win32_Logicaldisk -filter "deviceid='$($os.systemdrive)'" -ComputerName $computer
    }
    catch {
        #$_ is the error object
        Write-Warning "Failed to get OperatingSystem information from $computer. $($_.Exception.Message)"        
    }
    
} | Select PSComputername, DeviceID,
@{Name = "SizeGB"; Expression = {$_.Size / 1GB -as [int]}},
@{Name = "FreeGB"; Expression = {[math]::Round($_.Freespace / 1GB, 2)}} |
    Sort-Object FreeGB | Format-Table –AutoSize