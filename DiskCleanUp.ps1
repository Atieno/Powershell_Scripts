#****************** Parameters *******************
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$folder,
  
  [Parameter(Mandatory=$True,Position=2)]
  [int]$retentionDays,  
  
  [Parameter(Mandatory=$False)]
  [string]$backupFolder = $folder,
  
  [Parameter(Mandatory=$False)]
  [string]$extension = "*.*",
  
  [Parameter(Mandatory=$False)]
  [string]$exclude = "",  
	  
  [Parameter(Mandatory=$False)]
  [string]$zipFileName = "archive.zip",
  
  [Parameter(Mandatory=$True)]
  [ValidateSet("Archive","Delete")]
  [string]$action,

  [Parameter(Mandatory=$False)]
  [switch]$recurse,           
  
  [Parameter(Mandatory=$False)]
  [string]$7zipExe = "C:\Service\Scripts\GSMC\Utils\7zip\7za.exe",
  
  [Parameter(Mandatory=$False)]
  [switch]$test,
  
  #log delete messages to debug log file. Even with -WhatIf option
  [Parameter(Mandatory=$False)]
  [switch]$transcript
)

#****************** Defaults *********************
$date=Get-date -format "yyyyMMdd"
$rawname=$MyInvocation.MyCommand.Name.Split(".") 
$cleanname=$rawname[0].ToUpper()
$logpath="C:\service\Scripts\GSMC\Log\$cleanname.log"
$debuglogpath="C:\service\Scripts\GSMC\Logging\$cleanname.log"
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if ((Test-Path($logpath))){
	$islarge=(Get-Item $logpath).length -gt 5mb
	if ($islarge){
		Move-Item $logpath "$logpath.bak" -force
	}
}
if ((Test-Path($debuglogpath))){
	$islarge=(Get-Item $debuglogpath).length -gt 5mb
	if ($islarge){
		Move-Item $debuglogpath "$debuglogpath.bak" -force
	}
}

function log($message,$computer = $env:COMPUTERNAME){
	$message="$cleanname|$computer|$(Get-Date -format yyyyMMddHHmmss)|$message"
	$message|Out-File -FilePath $logpath -Append -enc ascii
  $message|Out-File -FilePath $debuglogpath -Append -enc ascii
}

function debuglog($message,$computer = $env:COMPUTERNAME){
	$message="$cleanname|$computer|$(Get-Date -format yyyyMMddHHmmss)|$message"
	$message|Out-File -FilePath $debuglogpath -Append -enc ascii
}
debuglog("$cleanname started!")

$end = {
  $stopWatch.Stop()
  debuglog([string]::Format("Script duration: {0:d2}:{1:d2}:{2:d2}.{3}",$stopWatch.Elapsed.Hours,$stopWatch.Elapsed.Minutes,$stopWatch.Elapsed.Seconds,$stopWatch.Elapsed.Milliseconds))
  debuglog("$cleanname ended!")
  exit
}
$stopWatch = [system.diagnostics.stopwatch]::startNew()

#********************* Script ********************
debuglog("Test mode: {0}" -f $test)
. ({$folder = $folder}, {$folder = $folder+"\*"})[!$recurse]

[array]$files = gci $folder -recurse:$recurse -include $extension -exclude $exclude| ? {(($_.CreationTime).Date -lt (get-date).AddDays(-$retentionDays).Date) -and -not $_.PSIsContainer}

write-host $folder -recurse:$recurse -include $extension -exclude $exclude | ? {(($_.CreationTime).Date -lt (get-date).AddDays(-$retentionDays).Date) -and -not $_.PSIsContainer}

if (!$files)
{
  log("No file for archiving has not been found")
  &$end
}

debuglog("Found files: {0}" -f $files.count)

$delete = {  
    if($transcript) {start-transcript "C:\service\Scripts\GSMC\Logging\DiskCleanup_transcript.txt" -Append}
  
    $files | % {
      $file = $_.FullName
         
      try {        
        ri $file -Confirm:$False -ErrorAction stop -WhatIf:$test
      }
      catch [System.Exception] {
        $ErrorMessage = $_.Exception.Message
        switch($_.Exception.GetType().FullName) {
          'System.Management.Automation.ItemNotFoundException' {
              Log("Error: Delete file '{0}' failed. File not found." -f $file)
              debugLog($ErrorMessage)($env:COMPUTERNAME)
          }
          'system.IO.IOException' {
              Log("Error: Delete file '{0}' failed. Not enough permission." -f $file)
              debugLog($ErrorMessage)
          }
        }
      } 
    }
    if($transcript) {stop-transcript}
    Log("Delete files from folder '{0}' finished." -f $folder)    
}

switch($action)
{
  "Archive" {
    cd $folder
    
    $files | % {
      $withSubFolders = $_.FullName.Substring($folder.length + 1,$_.FullName.Length - $folder.Length - 1)     
      Add-Content -path filenames.txt -value $withSubFolders
    }

    $zipSplit = $zipFileName.Split(".")
    $zipName = "{0}\{1}_{2}.{3}" -f $backupFolder,$zipSplit[0],$date,$zipSplit[1]
  
    &$7zipExe "a" $zipName "@filenames.txt"
    Log("Archived {0} files into zip file '{1}'." -f $files.count,$zipName)
    ri filenames.txt    
    
    $check = &$7zipExe "t" $zipName
    
    if(($check[($check.length - 5)] -and $files.count -gt 1) -eq "Everything is Ok")
    {
      $check[($check.length - 3)] -match "(\d+)$"
      $archivedFiles = $matches[1]
      
      debugLog("Archive files count: {0}" -f $archivedFiles)
      
      if($files.count -eq $archivedFiles)
      {
        debugLog("Deleting archived files from source folder...")          
        &$delete        
      } else {         
        log("Count of source files and archived files is not equal!")
      }
    
    }
    elseif(($check[($check.length - 4)] -and $files.count -eq 1) -eq "Everything is Ok")
    {
      debugLog("Archive files count: {0}" -f $archivedFiles)
      debugLog("Deleting archived files from source folder...")          
      &$delete
    }    
    else
    {
      Log("Zip file is corrupted.")
    }
  }
  "Delete" {
    &$delete
  }
}
&$end