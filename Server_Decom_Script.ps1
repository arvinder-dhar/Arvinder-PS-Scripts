#Author : Arvinder
#Description : Script will check PasswordLastSet Attribute and find out which servers are inactive since 45 days

    $domains = $null
    $domains = (Get-ADTrust -Filter * | Where-Object { $_.name -notlike "*abc*" -and $_.name -notlike "*xyz*" }).name #exclude certain servers with similar values in name
 
    $Final_Report = @()
 
    $lastSetdate = [DateTime]::Now - [TimeSpan]::Parse("45")
 
    foreach ( $domain in $domains) {
 
    [array]$servers = (Get-ADComputer -Filter { PasswordLastSet -le $lastSetdate } -Properties * -Server $domain | `
    Where-Object { $_.DNSHostname -notlike "*def*" -and $_.DNSHostname -notlike "*ghi*" }).DNSHostname #exclude certain servers with similar values in name
 
     foreach($server in $servers) {
 
     try {
 
           $ServerDetails = "" | Select ComputerName,passwordlastset,pingstatus
    
           $Server_netbios = $server.Split(".")[0]
           $date = (Get-ADComputer -Identity $Server_netbios -Properties * -Server $domain ).PasswordLastSet
           $passwordlastset = Get-Date $date -Format 'MM/dd/yyyy'
 
           $ServerDetails.ComputerName = $Server
           $ServerDetails.passwordlastset = $passwordlastset
 
           $ping_check = Test-Connection -ComputerName $server -Quiet
 
           if ( $ping_check -eq $true )
           { $ServerDetails.pingstatus = "Pingable" }
 
           else { $ServerDetails.pingstatus = "Not_Pingable" }
 
           $ServerDetails
           $Final_Report  += $ServerDetails
 
           }
       
    Catch {
 
          $ServerDetails = "" | Select ComputerName,passwordlastset,pingstatus
 
          $ServerDetails.ComputerName = $Server
          $ServerDetails.passwordlastset = "Information cannot be fetched"
          $ServerDetails.pingstatus ="NA"
       
          $ServerDetails
          $Final_Report  += $ServerDetails
 
          #Write-Warning "Domain : $domain not accessible"
 
 
          }
    
                                }
                                }
 
    $Final_Report
 