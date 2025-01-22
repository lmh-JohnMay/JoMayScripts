#$u=$null
#Clear-Variable -Name $u
Remove-Variable * -ErrorAction SilentlyContinue
#get-variable

Get-Service -ComputerName lmh-sqlis-t | where-object {$_.displayname -like '*sql*'} #lmh-sql2022-p