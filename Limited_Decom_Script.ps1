#Author : Arvinder
#Description : Script will check PasswordLastSet Attribute for certain servers that have been identified inactive earlier

$Final_Report = @()
$servers = $null
$ServerDetails = $null

$servers = Get-Content .\servers.txt

     foreach($server in $servers) {

     try {

            $split = $server.Split(".")
            $domain = $split[1]+"."+$split[2]+"."+$split[3]+"."+$split[4]

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

          Write-Warning "$server Not Reachable"
 

          } 
    
                                }
                                

   $Final_Report