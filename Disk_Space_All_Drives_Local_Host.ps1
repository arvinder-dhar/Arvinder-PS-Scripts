# Free Space and total space in all drives in GB for local machine

Get-wmiobject -computername localhost -class Win32_LogicalDisk | select -Property deviceid,@{n='total';e={$_.size/1gb -as [int]}},@{n='free';e={$_.freespace/1gb -as [int]}} | Format-Table -AutoSize
