
daniel.atieno@c23ptmr[/filer/gsmc/bin/benetton/tools]$ vim Update_staging_automatic3750.sh
#!/bin/bash
ep=$1
res1=`esfcmd -timeout 100 usob $ep 'rd c:\service\Agents\ESFClient\.\update\new\eSFClient_3.1.44  /S /Q & del C:\service\Agents\ESFClient\conf\monitors\bid_mon_v03.xml & del C:\service\Agents\ESFClient\conf\monitors\rc_mon_v01.xml'`
res1=`esfcmd -timeout 100 usob $ep 'c:\temp\7z.exe x c:\temp\Update_staging_automatic.zip -oC:\ -aoa'`
if [[ "$res1" == *7z.exe* ]] ; then
 res1=`esfput usob $ep '/filer/gsmc/bin/benetton/tools/data/7z.exe' 'c:\temp\7z.exe'`
 res1=`esfput usob $ep '/filer/gsmc/bin/benetton/tools/data/7z.dll' 'c:\temp\7z.dll'`
 res1=`esfcmd -timeout 100 usob $ep 'c:\temp\7z.exe x c:\temp\Update_staging_automatic.zip -oC:\ -aoa'`
fi
if [[ "$res1" == *ERROR* ]] ; then
 echo "Going to upload installation files to $ep"
 res1=`esfput -timeout 100 usob $ep '/filer/gsmc/bin/benetton/tools/data/Update_staging_automatic.zip' 'c:\temp\Update_staging_automatic.zip'`
 res1=`esfcmd -timeout 100 usob $ep 'c:\temp\7z.exe x c:\temp\Update_staging_automatic.zip -oC:\ -aoa'`
fi

echo "$ep": "$res1"
if [[ "$res1" == *initialized* ]] ; then
 usleep 270000000
 res1=`esfcmd -timeout 100 usob $ep 'c:\temp\7z.exe x c:\temp\Update_staging_automatic.zip -oC:\ -aoa'`
 echo "$ep": "$res1"
fi
if [[ "$res1" == *ERROR* ]] ; then
 exit 0
fi
#res1=`esfput -timeout 100 usob $ep '/filer/gsmc/bin/benetton/tools/data/Update_staging_automatic3750.cmd' 'c:\service\src\Update_staging_automatic3750.cmd'`
res1=`esfcmd -timeout 100 usob $ep 'c:\service\src\Update_staging_automatic3750.cmd'`
res1=`esfget usob $ep 'c:\service\src\Update_staging_automatic.log' /filer/gsmc/bin/benetton/tools/data/Update_staging_automatic/"$ep"_Update_staging_automatic.log`
if [[ "$res1" == *ERROR* ]] ; then
 echo "$ep": "$res1"
 exit 0
fi
grep deletion /filer/gsmc/bin/benetton/tools/data/Update_staging_automatic/"$ep"_Update_staging_automatic.log
if [[ "$?" -eq 0 ]] ; then
 esfcmd -timeout 15 usob $ep "shutdown -t 100 -r -f -d u:0:0 -c \"on demand reboot for service installation\"";
 usleep 270000000
 res1=`esfcmd -timeout 100 usob $ep 'c:\service\src\Update_staging_automatic3750.cmd'`
 res1=`esfget usob $ep 'c:\service\src\Update_staging_automatic.log' /filer/gsmc/bin/benetton/tools/data/Update_staging_automatic/"$ep"_Update_staging_automatic.log`
 if [[ "$res1" == *ERROR* ]] ; then
  echo "$ep": "$res1"
  exit 0
 fi
fi
echo $ep >> /filer/gsmc/bin/benetton/tools/data/Update_staging_automatic3750.EPlist
esfcmd -timeout 100 usob $ep 'powershell "start-service WNBID*,uvnc*,VNX*"'
if [[ "$?" -eq 2 ]] ; then
 esfcmd -timeout 15 usob $ep "shutdown -t 100 -r -f -d u:0:0 -c \"on demand reboot for service installation\"";
 usleep 270000000
 res1=`esfcmd -timeout 100 usob $ep 'c:\service\src\Update_staging_automatic3750.cmd'`
 res1=`esfget usob $ep 'c:\service\src\Update_staging_automatic.log' /filer/gsmc/bin/benetton/tools/data/Update_staging_automatic/"$ep"_Update_staging_automatic.log`
 if [[ "$res1" == *ERROR* ]] ; then
  echo "$ep": "$res1"
  exit 0
 fi
fi
echo "$ep: Script was finished."
~
~
~
~
~
~
~
~
~
