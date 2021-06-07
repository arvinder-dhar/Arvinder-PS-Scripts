## Description : Will create a folder on multiple servers fetched from notepad and copy particular setup 

$servers = Get-Content C:\Users\$env:userName\Desktop\Servers.txt

foreach ($server in $servers)

{

New-Item \\$server\c$\certain_folder -ItemType directory
Copy-Item \\***\public\PublicShare\Software\setup.exe -Destination \\$server\c$\certain_folder

Write-Verbose "$server Done" -Verbose

}