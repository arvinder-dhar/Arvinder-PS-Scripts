<# 
Author : Arvinder
Version : 5
Description : Script will seek info from the interactive console and will create group based on the input fields
Important : Some fields are mandatory and can't be skipped like OU(only in case of DMN1), Group Name (For all Domains)
Enhancements : 1. Error Handling
               2. Minimal scope for Human error during group creation
               3. Involvement of all Mandatory group fields like POC which earlier might have been skipped
#>

#####START#####

Function New-ARSGroup {

    write-Host "Choose the number for the respective domain" -ForegroundColor Green
    Write-Host "1 = Domain1 `n2 = Domain2 `n3 = Domain3" -ForegroundColor Green
    Write-Host ""
    
    $Domain_Selection = Read-Host 
    Write-Host ""
    
    #####Domain1#####
    
     if ($Domain_Selection -eq 1) {Write-Host "You have choosen Domain1" -ForegroundColor Cyan
    
     Connect-QADService -Service "domain1.xyz.com:389" | Out-Null
    
     Write-Host ""
     Write-Host "Make Container selection for Domain1"
     Write-Host "OU1 = xyz.com/ou1`nOU2 = xyz.com/ou2`nOU3 = xyz.com/ou3" -ForegroundColor Green
     Write-Host ""
    
    $ouselection = Read-Host #OU Name : Mandatory
    if ($ouselection -like "OU1") {$OU = "OU1 Path DN"}
     if ($ouselection -like "OU2") {$OU = "OU2 Path DN"}
      if ($ouselection -like "OU3") {$OU = "OU3 Path DN"}
    
     if ($ouselection -like "OU1" -or $ouselection -like "OU2") {
     
     Write-Host "" 
     Write-Host "You have Selected '$ouselection' OU`nSome Options will be Default choosen as per OU" -ForegroundColor Cyan
     Write-Host ""
    
     $groupname = Read-Host "Enter the group name"  #Name and SAMAccountname : Mandatory
     $groupname = $groupname.Trim() # Trim the spaces in group name
    
     $groupcheck = [bool](get-QADGroup -LdapFilter "(name=$groupname)")
    
     if ($groupcheck -eq $true) {
     Write-Warning "$groupname already exist in Domain1"
     break}
    
     else {
    
     $groupscopecheck = $groupname.Substring(0,1)
    
     if ($groupscopecheck -like "g") {$groupscope = "Global"}
     if ($groupscopecheck -like "l") {$groupscope = "DomainLocal"}
     if ($groupscopecheck -notlike "g" -and $groupscopecheck -notlike "l") {
     Write-Warning "Group Name should start with either 'G' or 'L'"
     break
     }
    
     $grouplength = $groupname.Length #Group Length Check
     if ($grouplength -gt 63){
     Write-Warning "Group Size shouldn't be greater than 63 Characters"
     break
     }
    
     $grouptype = "Security"

     $priv_check = $groupname.Contains("priv")
     $restrict_check = $groupname.Contains("restr")

    if ($priv_check -eq $true -or $restrict_check -eq $true) {

        if ($priv_check -eq $true) {
        $ObjectType = 'PR'
        Write-Host ""
        Write-Host "Object Type will be set as PR" -ForegroundColor Cyan
     }

        else {
        $ObjectType = 'MA'
        Write-Host ""
        Write-Host "Object Type will be set as MA" -ForegroundColor Cyan
     }
    }

    else {
    
     Write-Host ""
     Write-Host "Choose the ObjectType"
     Write-Host "LR = Label Required`nMA = MA`nPR = PR`nGE = GE`nPE = PE" -ForegroundColor Green
     Write-Host ""
    
     $Objecttypeselection = Read-Host
     if ($Objecttypeselection -like "LR") {$ObjectType = 'LR'}
      if ($Objecttypeselection -like "MA") {$ObjectType = 'MA'}
       if ($Objecttypeselection -like "PR") {$ObjectType = 'PR'}
        if ($Objecttypeselection -like "GE") {$ObjectType = 'GE'}
          if ($Objecttypeselection -like "PE") {$ObjectType = 'PE'}
    
    if ($Objecttypeselection -notlike "LR" -and $Objecttypeselection -notlike "MA" -and $Objecttypeselection -notlike "PR" -and $Objecttypeselection -notlike "GE" -and $Objecttypeselection -notlike "PE"){
    Write-Warning "Incorrect Selection for ObjectType!!"
    break
    }
    }
    
    Write-Host ""
    
     #Other Parameter values
    
     $groupowner = Read-Host "Enter the Group Owner"  #edsvaGroupOwner 
      $Businessdescription = Read-Host "Enter the Business description" #edsvaGroupBusinessDescription 
       $Dependencies = Read-Host "Enter the Dependencies" #edsvaGroupDependencies 
        $Entitlement = Read-Host "Enter the Entitlement" #edsvaGroupEntitlements
         $WhoCreated = Read-Host "Enter the Who Created" #edsvaGroupCreator
          $Requesttype = Read-Host "Enter the Request type"  #edsvaGroupRequestInfo 
           $Requestnumber = Read-Host "Enter the Request number"  #edsvaGroupRequestNumber
            $primaryowner = Read-Host "Write the Primary Owner" #wWWHomePage
             $secondaryowner = Read-Host "Write the Secondary Owner" #labeledURI
    
    #Trim the Spaces here
    
     $groupowner = $groupowner.Trim()  #edsvaGroupOwner 
      $Businessdescription = $Businessdescription.Trim() #edsvaGroupBusinessDescription 
       $Dependencies = $Dependencies.Trim() #edsvaGroupDependencies 
        $Entitlement = $Entitlement.Trim() #edsvaGroupEntitlements
         $WhoCreated = $WhoCreated.Trim() #edsvaGroupCreator
          $Requesttype = $Requesttype.Trim()  #edsvaGroupRequestInfo 
           $Requestnumber = $Requestnumber.Trim()  #edsvaGroupRequestNumber
            $primaryowner = $primaryowner.Trim() #wWWHomePage
             $secondaryowner = $secondaryowner.Trim() #labeledURI
    
    ##Group Creation Here
    
    $primaryowner_check = [bool](Get-QADUser $primaryowner -Service "domain1.xyz.com:389")
    $secondaryowner_check = [bool](Get-QADUser $secondaryowner -Service "domain1.xyz.com:389")

    $primary_prefix_check = $primaryowner.StartsWith('a')
    $secondary_prefix_check = $secondaryowner.StartsWith('a')
    
    if ($primaryowner_check -eq $false -or $secondaryowner_check -eq $false -or $primary_prefix_check -eq $false -or $secondary_prefix_check -eq $false){
    Write-Warning "Enter a valid CorpID Only!!"
    Break
    }
    
    else {
    
    New-QADGroup -ParentContainer $OU -Name $groupname -SamAccountName $groupname -DisplayName $groupname -GroupScope $groupscope -GroupType $grouptype -ObjectAttributes @{edsvaGroupOwner=$groupowner;edsvaGroupBusinessDescription=$Businessdescription;edsvaGroupDependencies=$Dependencies; edsvaGroupEntitlements=$Entitlement; edsvaGroupCreator=$WhoCreated;edsvaGroupRequestInfo=$Requesttype;edsvaGroupRequestNumber=$Requestnumber;ObjectType=$ObjectType;wWWHomePage=$primaryowner;labeledURI=$secondaryowner} -Proxy | Out-Null
    
    Write-Host "Group : $groupname has been created in Domain1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To verify the group has been created, Run below command after 5-10 Seconds`nGet-QADGroup $groupname -Service 'domain1.xyz.com:389'" -ForegroundColor Green
    Write-Host ""
    }
    
    }
    
    }
    
     elseif ($ouselection -like "OU3") {
     
     Write-Host "" 
     Write-Host "You have Selected '$ouselection' OU`nSome Options will be Default choosen as per OU" -ForegroundColor Cyan
     Write-Host ""
    
     $groupname = Read-Host "Enter the group name"  #Name and SAMAccountname : Mandatory
     $groupname = $groupname.Trim() # Trim the spaces in group name
    
     $groupcheck = [bool](get-QADGroup -LdapFilter "(name=$groupname)")
    
     if ($groupcheck -eq $true) {
     Write-Warning "$groupname already exist in Domain1"
     break}
    
     else {
    
     $grouplength = $groupname.Length #Group Length Check
     if ($grouplength -gt 63){
     Write-Warning "Group Size shouldn't be greater than 63 Characters"
     break
     }
    
     $groupnamecheck = $groupname.Substring(0,3)
     if ($groupnamecheck -notlike "azg") {
     Write-Warning "Group Should Start with Prefix:EFG!!"
     break
     }
    
    
     $groupscope = "Universal"
     $grouptype = "Distribution"
     $ObjectType = "AGroup"
    
    Write-Host ""
    
    #Other Parameter values
    
     $groupowner = Read-Host "Enter the Group Owner"  #edsvaGroupOwner 
      $Businessdescription = Read-Host "Enter the Business description" #edsvaGroupBusinessDescription 
       $Dependencies = Read-Host "Enter the Dependencies" #edsvaGroupDependencies 
        $Entitlement = Read-Host "Enter the Entitlement" #edsvaGroupEntitlements
         $WhoCreated = Read-Host "Enter the Who Created" #edsvaGroupCreator
          $Requesttype = Read-Host "Enter the Request type"  #edsvaGroupRequestInfo 
           $Requestnumber = Read-Host "Enter the Request number"  #edsvaGroupRequestNumber
            $primaryowner = Read-Host "Write the Primary Owner" #wWWHomePage
             $secondaryowner = Read-Host "Write the Secondary Owner" #labeledURI
    
    #Trim the Spaces here
    
     $groupowner = $groupowner.Trim()  #edsvaGroupOwner 
      $Businessdescription = $Businessdescription.Trim() #edsvaGroupBusinessDescription 
       $Dependencies = $Dependencies.Trim() #edsvaGroupDependencies 
        $Entitlement = $Entitlement.Trim() #edsvaGroupEntitlements
         $WhoCreated = $WhoCreated.Trim() #edsvaGroupCreator
          $Requesttype = $Requesttype.Trim()  #edsvaGroupRequestInfo 
           $Requestnumber = $Requestnumber.Trim()  #edsvaGroupRequestNumber
            $primaryowner = $primaryowner.Trim() #wWWHomePage
             $secondaryowner = $secondaryowner.Trim() #labeledURI
    
    ##Group Creation Here
    
    $primaryowner_check = [bool](Get-QADUser $primaryowner -Service "domain1.xyz.com:389")
    $secondaryowner_check = [bool](Get-QADUser $secondaryowner -Service "domain1.xyz.com:389")
    
    $primary_prefix_check = $primaryowner.StartsWith('a')
    $secondary_prefix_check = $secondaryowner.StartsWith('a')
    
    if ($primaryowner_check -eq $false -or $secondaryowner_check -eq $false -or $primary_prefix_check -eq $false -or $secondary_prefix_check -eq $false){
    Write-Warning "Enter a valid CorpID Only!!"
    Break
    }
    
    else {
    
    New-QADGroup -ParentContainer $OU -Name $groupname -SamAccountName $groupname -DisplayName $groupname -GroupScope $groupscope -GroupType $grouptype -ObjectAttributes @{edsvaGroupOwner=$groupowner;edsvaGroupBusinessDescription=$Businessdescription;edsvaGroupDependencies=$Dependencies; edsvaGroupEntitlements=$Entitlement; edsvaGroupCreator=$WhoCreated;edsvaGroupRequestInfo=$Requesttype;edsvaGroupRequestNumber=$Requestnumber;ObjectType=$ObjectType;wWWHomePage=$primaryowner;labeledURI=$secondaryowner} -Proxy | Out-Null
    
    Write-Host "Group : $groupname has been created in Domain1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To verify the group has been created, Run below command after 5-10 Seconds`nGet-QADGroup $groupname -Service 'domain1.xyz.com:389'" -ForegroundColor Green
    Write-Host ""
    
    }
    
    }
    
    }
    
     else {
     Write-Warning "Incorrect OU Selection !!"
     break
     }
     
     }
    
    #####Domain2#####
    
    elseif ($Domain_Selection -eq 2) {Write-Host "You have choosen Domain2" -ForegroundColor Cyan
    
     Connect-QADService -Service "domain2.xyz.com:389" | Out-Null
     Write-Host ""
    
     $OU = "Domain2_OU1_DN"
     $groupname = Read-Host "Enter the group name"  #Name and SAMAccountname : Mandatory
     $groupname = $groupname.Trim() # Trim the spaces in group name
    
     $groupcheck = [bool](get-QADGroup -LdapFilter "(name=$groupname)")
    
     if ($groupcheck -eq $true) {
     Write-Warning "$groupname already exist in Domain2"
     break}
    
     else {
    
     $groupscopecheck = $groupname.Substring(0,1)
    
     if ($groupscopecheck -like "g") {$groupscope = "Global"}
     if ($groupscopecheck -like "l") {$groupscope = "DomainLocal"}
     if ($groupscopecheck -notlike "g" -and $groupscopecheck -notlike "l") {
     Write-Warning "Group Name should start with either 'G' or 'L'"
     break
     }
    
     $grouplength = $groupname.Length #Group Length Check
     if ($grouplength -gt 63){
     Write-Warning "Group Size shouldn't be greater than 63 Characters"
     break
     }
    
     $grouptype = "Security"

     $priv_check = $groupname.Contains("priv")
     $restrict_check = $groupname.Contains("restr")

    if ($priv_check -eq $true -or $restrict_check -eq $true) {

        if ($priv_check -eq $true) {
        $ObjectType = 'PR'
        Write-Host ""
        Write-Host " Object Type will be set as PR" -ForegroundColor Cyan
     }

        else {
        $ObjectType = 'MA'
        Write-Host ""
        Write-Host " Object Type will be set as MA" -ForegroundColor Cyan
     }
    }

    else {
    
     Write-Host ""
     Write-Host "Choose the ObjectType"
     Write-Host "LR = Label Required`nMA = MA`nPR = PR`nGE = GE`nPE = PE" -ForegroundColor Green
     Write-Host ""
    
     $Objecttypeselection = Read-Host
     if ($Objecttypeselection -like "LR") {$ObjectType = 'LR'}
      if ($Objecttypeselection -like "MA") {$ObjectType = 'MA'}
       if ($Objecttypeselection -like "PR") {$ObjectType = 'PR'}
        if ($Objecttypeselection -like "GE") {$ObjectType = 'GE'}
          if ($Objecttypeselection -like "PE") {$ObjectType = 'PE'}
    
    if ($Objecttypeselection -notlike "LR" -and $Objecttypeselection -notlike "MA" -and $Objecttypeselection -notlike "PR" -and $Objecttypeselection -notlike "GE" -and $Objecttypeselection -notlike "PE"){
    Write-Warning "Incorrect Selection for ObjectType!!"
    break
    }
    }
    
    Write-Host ""
    
     #Other Parameter values
    
     $groupowner = Read-Host "Enter the Group Owner"  #edsvaGroupOwner 
      $Businessdescription = Read-Host "Enter the Business description" #edsvaGroupBusinessDescription 
       $Dependencies = Read-Host "Enter the Dependencies" #edsvaGroupDependencies 
        $Entitlement = Read-Host "Enter the Entitlement" #edsvaGroupEntitlements
         $WhoCreated = Read-Host "Enter the Who Created" #edsvaGroupCreator
          $Requesttype = Read-Host "Enter the Request type"  #edsvaGroupRequestInfo 
           $Requestnumber = Read-Host "Enter the Request number"  #edsvaGroupRequestNumber
            $primaryowner = Read-Host "Write the Primary Owner" #wWWHomePage
             $secondaryowner = Read-Host "Write the Secondary Owner" #labeledURI
    
     #Trim the Spaces here
    
     $groupowner = $groupowner.Trim()  #edsvaGroupOwner 
      $Businessdescription = $Businessdescription.Trim() #edsvaGroupBusinessDescription 
       $Dependencies = $Dependencies.Trim() #edsvaGroupDependencies 
        $Entitlement = $Entitlement.Trim() #edsvaGroupEntitlements
         $WhoCreated = $WhoCreated.Trim() #edsvaGroupCreator
          $Requesttype = $Requesttype.Trim()  #edsvaGroupRequestInfo 
           $Requestnumber = $Requestnumber.Trim()  #edsvaGroupRequestNumber
            $primaryowner = $primaryowner.Trim() #wWWHomePage
             $secondaryowner = $secondaryowner.Trim() #labeledURI
    
    ##Group Creation Here
    
    $primaryowner_check = [bool](Get-QADUser $primaryowner -Service "domain1.xyz.com:389")
    $secondaryowner_check = [bool](Get-QADUser $secondaryowner -Service "domain1.xyz.com:389")
    
    $primary_prefix_check = $primaryowner.StartsWith('a')
    $secondary_prefix_check = $secondaryowner.StartsWith('a')
    
    if ($primaryowner_check -eq $false -or $secondaryowner_check -eq $false -or $primary_prefix_check -eq $false -or $secondary_prefix_check -eq $false){
    Write-Warning "Enter a valid CorpID Only!!"
    Break
    }
    
    else {
    
    New-QADGroup -ParentContainer $OU -Name $groupname -SamAccountName $groupname -DisplayName $groupname -GroupScope $groupscope -GroupType $grouptype -ObjectAttributes @{edsvaGroupOwner=$groupowner;edsvaGroupBusinessDescription=$Businessdescription;edsvaGroupDependencies=$Dependencies; edsvaGroupEntitlements=$Entitlement; edsvaGroupCreator=$WhoCreated;edsvaGroupRequestInfo=$Requesttype;edsvaGroupRequestNumber=$Requestnumber;ObjectType=$ObjectType;wWWHomePage=$primaryowner;labeledURI=$secondaryowner} -Proxy | Out-Null
    
    Write-Host "Group : $groupname has been created in Domain2" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To verify the group has been created, Run below command after 5-10 Seconds`nGet-QADGroup $groupname -Service 'domain2.xyz.com:389'" -ForegroundColor Green
    Write-Host ""
    }
    
     }
    
     }
    
     #####Domain3#####
    
    elseif ($Domain_Selection -eq 3) {Write-Host "You have choosen Domain3" -ForegroundColor Cyan
    
     Connect-QADService -Service "domain3.xyz.com:389" | Out-Null
     Write-Host ""
    
     $OU = "Domain3_OU1_DN"
     $groupname = Read-Host "Enter the group name"  #Name and SAMAccountname : Mandatory
     $groupname = $groupname.Trim() # Trim the spaces in group name
    
     $groupcheck = [bool](get-QADGroup -LdapFilter "(name=$groupname)")
    
     if ($groupcheck -eq $true) {
     Write-Warning "$groupname already exist in Domain3"
     break}
    
     $grouplength = $groupname.Length #Group Length Check
     if ($grouplength -gt 63){
     Write-Warning "Group Size shouldn't be greater than 63 Characters"
     break
     }

     $priv_check = $groupname.Contains("priv")
     $restrict_check = $groupname.Contains("restr")

    if ($priv_check -eq $true -or $restrict_check -eq $true) {

        if ($priv_check -eq $true) {
        $ObjectType = 'PR'
        Write-Host ""
        Write-Host " Object Type will be set as PR" -ForegroundColor Cyan
     }

        else {
        $ObjectType = 'MA'
        Write-Host ""
        Write-Host " Object Type will be set as MA" -ForegroundColor Cyan
     }
    }

    else{
    
     Write-Host ""
     Write-Host "Choose the ObjectType"
     Write-Host "LR = Label Required`nMA = MA`nPR = PR`nGE = GE`nPE = PE" -ForegroundColor Green
     Write-Host ""
    
     $Objecttypeselection = Read-Host
     if ($Objecttypeselection -like "LR") {$ObjectType = 'LR'}
      if ($Objecttypeselection -like "MA") {$ObjectType = 'MA'}
       if ($Objecttypeselection -like "PR") {$ObjectType = 'PR'}
        if ($Objecttypeselection -like "GE") {$ObjectType = 'GE'}
          if ($Objecttypeselection -like "PE") {$ObjectType = 'PE'}
    
    if ($Objecttypeselection -notlike "LR" -and $Objecttypeselection -notlike "MA" -and $Objecttypeselection -notlike "PR" -and $Objecttypeselection -notlike "GE" -and $Objecttypeselection -notlike "PE"){
    Write-Warning "Incorrect Selection for ObjectType!!"
    break
    }
    }
     
     Write-Host ""
     Write-Host "Choose the group Scope as per option"
     Write-Host "D = Domain Local`nG = Global" -ForegroundColor Green
     Write-Host ""
    
     $scopeselection = Read-Host
     if ($scopeselection -like "D") {$groupscope = "DomainLocal"}
      if ($scopeselection -like "G") {$groupscope = "Global"}
       if ($scopeselection -notlike "D" -and $scopeselection -notlike "G") {
            Write-Warning "Choose the Correct Group Scope!!`nSelect Either 'D' or 'G'"
            break
     }
     
     Write-Host ""
    
     $grouptype = "Security"
    
    Write-Host ""
    
     #Other Parameter values
    
     $groupowner = Read-Host "Enter the Group Owner"  #edsvaGroupOwner 
      $Businessdescription = Read-Host "Enter the Business description" #edsvaGroupBusinessDescription 
       $Dependencies = Read-Host "Enter the Dependencies" #edsvaGroupDependencies 
        $Entitlement = Read-Host "Enter the Entitlement" #edsvaGroupEntitlements
         $WhoCreated = Read-Host "Enter the Who Created" #edsvaGroupCreator
          $Requesttype = Read-Host "Enter the Request type"  #edsvaGroupRequestInfo 
           $Requestnumber = Read-Host "Enter the Request number"  #edsvaGroupRequestNumber
            $primaryowner = Read-Host "Write the Primary Owner" #wWWHomePage
             $secondaryowner = Read-Host "Write the Secondary Owner" #labeledURI
    
     #Trim the Spaces here
    
     $groupowner = $groupowner.Trim()  #edsvaGroupOwner 
      $Businessdescription = $Businessdescription.Trim() #edsvaGroupBusinessDescription 
       $Dependencies = $Dependencies.Trim() #edsvaGroupDependencies 
        $Entitlement = $Entitlement.Trim() #edsvaGroupEntitlements
         $WhoCreated = $WhoCreated.Trim() #edsvaGroupCreator
          $Requesttype = $Requesttype.Trim()  #edsvaGroupRequestInfo 
           $Requestnumber = $Requestnumber.Trim()  #edsvaGroupRequestNumber
            $primaryowner = $primaryowner.Trim() #wWWHomePage
             $secondaryowner = $secondaryowner.Trim() #labeledURI
    
    ##Group Creation Here
    
    $primaryowner_check = [bool](Get-QADUser $primaryowner -Service "domain1.xyz.com:389")
    $secondaryowner_check = [bool](Get-QADUser $secondaryowner -Service "domain1.xyz.com:389")
    
    $primary_prefix_check = $primaryowner.StartsWith('a')
    $secondary_prefix_check = $secondaryowner.StartsWith('a')
    
    if ($primaryowner_check -eq $false -or $secondaryowner_check -eq $false -or $primary_prefix_check -eq $false -or $secondary_prefix_check -eq $false){
    Write-Warning "Enter a valid CorpID Only!!"
    Break
    }
    
    else {
    
    New-QADGroup -ParentContainer $OU -Name $groupname -SamAccountName $groupname -DisplayName $groupname -GroupScope $groupscope -GroupType $grouptype -ObjectAttributes @{edsvaGroupOwner=$groupowner;edsvaGroupBusinessDescription=$Businessdescription;edsvaGroupDependencies=$Dependencies; edsvaGroupEntitlements=$Entitlement; edsvaGroupCreator=$WhoCreated;edsvaGroupRequestInfo=$Requesttype;edsvaGroupRequestNumber=$Requestnumber;ObjectType=$ObjectType;wWWHomePage=$primaryowner;labeledURI=$secondaryowner} -Proxy | Out-Null
    
    Write-Host "Group : $groupname has been created in Domain3" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To verify the group has been created, Run below command after 5-10 Seconds`nGet-QADGroup $groupname -Service 'domain3.xyz.com:389'" -ForegroundColor Green
    Write-Host ""
    }
     
    }
    
    
    else {Write-Warning "Incorrect Domain Selection !!`nChoose either of the value : 1, 2 or 3"} 
    
}

#####END#####
