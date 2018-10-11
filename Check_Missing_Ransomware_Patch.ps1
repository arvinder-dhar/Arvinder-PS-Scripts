#Author : Arvinder
#Description : Script will check for servers that have missing patch to eradicate Ransomware Attack


$Final_Result = $null

[array]$servers = Get-Content .\servers.txt

 foreach($server in $servers){

 $result = Get-HotFix -id KB4012213 -ComputerName $server

 $Fix = [bool](Get-HotFix -id KB4012213 -ComputerName $server -ErrorAction SilentlyContinue)
 

 if ($Fix -eq "True"){
  
       [array]$Final_Result += $result   
           
    }
else {

      $Fail = "$server : No Hotfix"
       [array]$Final_Result += $Fail  

    }
}

$Final_Result