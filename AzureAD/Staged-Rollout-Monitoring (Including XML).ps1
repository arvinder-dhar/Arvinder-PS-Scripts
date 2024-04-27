######Start######

<# Author: Arvinder
  Short Description : Monitor the membership count for groups scoped to Staged Rollout Features Namely PHS and SSSO
  Scope : 
        1. Password Hash Sync
        2. Seamless Single Sign-On

  HTML Editor Reference URL's : 
    1. https://www.w3schools.com/html/
    2. https://www.tablesgenerator.com/html_tables

#>

Function Get-GroupMemberCountDetails {
  [CmdletBinding()]
  Param(
    #Want to support multiple computers
    [Parameter(Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
    [String[]]$Groups,
    [String]$Feature
  )

  Begin {}
  Process {

    foreach ($Group in $Groups) {

      try {

        $Group_member_Count = (Get-ADGroup $Group -Properties member).member.count

        $property = [ordered] @{
          'Group Name'   = $Group ;
          'Feature'      = $Feature ;
          'Member Count' = $Group_member_Count ;
        }

      }
     
      Catch {

        $property = [ordered] @{
          'Group Name'   = $Group ;
          'Feature'      = $Feature ;
          'Member Count' = "Not Found in Directory" ;
        }
     
      }

      $Object = New-Object -TypeName PSObject -Property $property
      Write-Output $Object

    }

  }

  End {}

}
###########

Set-Location D:\ScheduledTasks\Directory\AzureAD\CloudAuth\Staged-Rollout-Monitoring

[XML]$Config = Get-Content .\ProdConfig.xml

## Data extraction
$PHS_Data = Get-GroupMemberCountDetails -Groups $Config.Prod.Staged_Rollout.Password_Hash_Sync.Group -Feature "Password Hash Sync"
$Seamless_SSO_Data = Get-GroupMemberCountDetails -Groups $Config.Prod.Staged_Rollout.Seamless_SSO.Group -Feature "Seamless SSO"

$currentdate = (Get-Date).ToShortDateString()
$report = $PHS_Data + $Seamless_SSO_Data
$report | Export-Csv ".\Reports\Staged-Rollout-Groups-$currentdate.csv".Replace("/", "-") -NoTypeInformation

$attachment = @(".\Reports\Staged-Rollout-Groups-$currentdate.csv".Replace("/", "-"))

## Check if need to Alert or not
#-or $_."Member Count" -like "Not Found in Directory"
$PHS_data_alert = ($PHS_Data | Where-Object { $_."Member Count" -ge 46000 } | Measure-Object).count
$Seamless_SSO_data_alert = ($Seamless_SSO_Data | Where-Object { $_."Member Count" -ge 46000 } | Measure-Object).count

$alert = $PHS_data_alert + $Seamless_SSO_data_alert

if ($alert -ne 0) {

  ## Mail Details
  $From = $Config.Prod.EmailConfig.From
  $To = $Config.Prod.EmailConfig.To
  $smtp = $Config.Prod.EmailConfig.SMTPServer

  ## Body Details
  $Body_part = Get-Date -Format "MMM-dd-yyyy"
  $Subject = $Config.Prod.EmailConfig.Subject + '-' + $Body_part

  $Body += "<font
  color=red><font size='+2'>Warning : Groups found that are nearing Staged Rollout Member Count limit of 50K (or) they are not present in Directory <br>
  <font
  color=black><font size='+1'>Please refer the attachment
"
  Send-MailMessage -From $From -To $To -Attachments $attachment -SmtpServer $smtp -Subject $Subject -Body $Body -BodyAsHtml
}

<#
XML

<?xml version="1.0"?>
<Prod>
	<Staged_Rollout>
		<Password_Hash_Sync>
			<Group>Group1</Group>
			<Group>Group2</Group>
			<Group>Group3</Group>
			<Group>Group4</Group>
		</Password_Hash_Sync>

		<Seamless_SSO>
			<Group>Group1</Group>
			<Group>Group4</Group>
		</Seamless_SSO>
	</Staged_Rollout>
	
	<EmailConfig>
        <Subject>Warning: Staged Rollout Limit Near Exceeding</Subject>
        <From>something.here@gmail.com</From>
        <To>something1.here@gmail.com</To>
		<To>something2.here@gmail.com</To>
        <SMTPServer>smtpserver.com</SMTPServer>
    </EmailConfig>	
</Prod>

#>

###### END #####

