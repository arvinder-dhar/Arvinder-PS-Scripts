##Author : Arvinder
##Description : Script will get the windows update settings for the servers list fetched from servers.txt file
##Modifications : Script stores the output in excel file
##Shortcomings: Error handling
##Version : 2

#####START#####

$final_report = @()

$job = Invoke-Command -ComputerName (Get-Content C:\servers.txt) -ScriptBlock {
 
  $key =  'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
  $setting = (Get-ItemProperty -Path $key -Name AUoptions).AUoptions

  if ($setting -eq 1) 
  {$report = "$(hostname) : Never Check for updates"}

  if ($setting -eq 2) 
  {$report = "$(hostname) : Notify for download and notify for install"}

  if ($setting -eq 3) 
  {$report = "$(hostname) : Auto download and notify for install"}

  if ($setting -eq 4) 
  {$report = "$(hostname) : Auto download and schedule the install"}

  if ($setting -eq 5) 
  {$report = "$(hostname) : Allow local admin to choose setting"}

  $final_report += $report
  $final_report
   
    
} -ErrorAction SilentlyContinue -AsJob


Wait-Job $job

$result = Receive-Job $job

$result | Export-Excel Patch_settings.xlsx

#####END#####