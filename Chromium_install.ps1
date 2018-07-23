#roll-back of previous install try
c:\temp\7z.exe a -rmx0 c:\temp\Chromium_install_bin_backup.zip "C:\TPDotnet\bin\*.dll"
<#
cd c:\tpdotnet\bin
copy-item TPDotnet.Pos.exe.config.bak TPDotnet.Pos.exe.config
cd c:\tpdotnet\POS\cfg
copy-item WebPlayer.xml.bak WebPlayer.xml
#>
c:\temp\7z.exe x c:\temp\Chromium_install.zip -oC:\temp\Chromium_install\ -y
$ErrorActionPreference="stop"
C:\Temp\Chromium_install\NDP40-KB2468871-v2-x86.exe /q /log C:\Temp\Chromium_install_NDP40-KB2468871-v2-x86
C:\Temp\Chromium_install\vcredist_x86.exe /q /log C:\Temp\Chromium_install_vcredist_x86
Stop-Service tp*
Get-Process tp* | Stop-Process -force
Get-Process ts* | Stop-Process -force
cd C:\Temp\Chromium_install
Copy-Item -Recurse .\bin C:\TPDotnet -force
Start-Service tp* -Exclude *Communication*
cd c:\tpdotnet\bin
copy-item TPDotnet.Pos.exe.config TPDotnet.Pos.exe.config.bak
$puvodni=@"
<NetFx40_LegacySecurityPolicy enabled="true"/>
"@
$nova=@"
<NetFx40_LegacySecurityPolicy enabled="true"/>
      <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
      <dependentAssembly>
        <assemblyIdentity name="System.IO" publicKeyToken="b03f5f7f11d50a3a" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-2.6.10.0" newVersion="2.6.10.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="System.Runtime" publicKeyToken="b03f5f7f11d50a3a" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-2.6.10.0" newVersion="2.6.10.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="System.Threading.Tasks" publicKeyToken="b03f5f7f11d50a3a" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-2.6.10.0" newVersion="2.6.10.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="System.Runtime" publicKeyToken="b03f5f7f11d50a3a" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-2.6.10.0" newVersion="2.6.10.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="System.Threading.Tasks" publicKeyToken="b03f5f7f11d50a3a" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-2.6.10.0" newVersion="2.6.10.0" />
      </dependentAssembly>
    </assemblyBinding>
"@
$ErrorActionPreference="silentlycontinue"
Get-Content TPDotnet.Pos.exe.config.bak | ForEach-Object { $_ -replace "$puvodni", "$nova" } | Set-Content ("TPDotnet.Pos.exe.config")
cd c:\tpdotnet\POS\cfg
copy-item WebPlayer.xml WebPlayer.xml.bak
$puvodni=@"
</Parameters>
"@
$nova=@"
        <ButtonBack>True</ButtonBack>
        <CefSetting.UserAgent>Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36</CefSetting.UserAgent>
        <FolderforSaveFiles>C:\Users\TPAdmin\Downloads</FolderforSaveFiles>
</Parameters>
"@
Get-Content WebPlayer.xml.bak | ForEach-Object { $_ -replace "$puvodni", "$nova" } | Set-Content ("WebPlayer.xml")
#shutdown -r -t 30 -f
