#Author : Arvinder
#Description : TO find out servers that have Mcafee installed on them

Remove-Item \\server\C$\Users\adm-adhar\Desktop\mcafee_report.xlsx -ErrorAction SilentlyContinue

$final_report = $null
$servers = $null

$servers = Get-Content C:\Users\$env:username\desktop\mcafee.txt

foreach ( $server in $servers) {

 $remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
 $ping = Test-Connection -ComputerName $server -Quiet
 
  if ($remote -eq "True" -and $ping -eq "True"){

  try {
  
       #Creating a Table

       $ServerDetails = "" | Select ServerName,Mcafee_status

       $ServerDetails.ServerName = $server
       $mcafee_check = [bool](Get-WmiObject -ComputerName $server -Class win32_product | Where-Object {$_.Name -like "mcafee*"})

       if ($mcafee_check -eq $true)
       {$ServerDetails.Mcafee_status = "McAfee Present"}

      
       if ($mcafee_check -eq $false)
       {$ServerDetails.Mcafee_status = "McAfee Not Present"}

       $ServerDetails
       [array]$final_report += $ServerDetails

       }

  Catch{

      $ServerDetails = "" | Select ServerName,Mcafee_status

      $ServerDetails.ServerName = $server
      $ServerDetails.Mcafee_status = "Server either down or not reachable"

      $ServerDetails
      [array]$final_report += $ServerDetails

     }
   
    }

else {

      $ServerDetails = "" | Select ServerName,Mcafee_status

      $ServerDetails.ServerName = $server
      $ServerDetails.Mcafee_status = "Server either down or not reachable"

      $ServerDetails
      [array]$final_report += $ServerDetails
      
    }
}

$final_report | Export-Excel '\\server\c$\Users\$env:username\desktop\mcafee_report.xlsx' -AutoSize

$From = "sendermailid"
$To = "receiptmailid"

$attachment = @("\\server\c$\Users\$env:username\desktop\mcafee_report.xlsx")

$smtp = "smtp server"
$Subject = "McAfee Report"

Send-MailMessage -From $From -To $To -Attachments $attachment -SmtpServer $smtp -Subject $Subject