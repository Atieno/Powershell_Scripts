[CmdletBinding()]
#powershell Shell.Application
$Shell=New-Object -ComObject Shell.Application
Get-ChildItem ("C:\Backup\CallerTable\*.xls*")