Function Get-StrongCrypto{
    Write-Host "$env:COMPUTERNAME" -ForegroundColor Red -BackgroundColor Green
    Write-Output "`nStrong Crypto $env:COMPUTERNAME"
    Get-ItemProperty -Path "hklm:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727"  -Name 'SchUseStrongCrypto' -ErrorAction SilentlyContinue
    $?
    Get-ItemProperty -Path "hklm:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"  -Name 'SchUseStrongCrypto' -ErrorAction SilentlyContinue
    $?
    Write-Host "--------------------------------`n" -ForegroundColor Green
}

Function Get-SSLV2.0{
    Write-Output "Get-SSL V2.0 $env:COMPUTERNAME"
    if(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\" )
    {
        Get-ChildItem "hklm:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\"
        reg export "hklm\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0" C:\temp\SSL_2.reg /y
    }
    else{
        Write-Warning "SSL 2.0 Registry is not available"
    }
    Write-Host "--------------------------------`n" -ForegroundColor Green
}

Function Get-SSLV3.0{
    Write-Output "Get-SSL V3.0 $env:COMPUTERNAME"
    if(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\" )
    {
        Get-ChildItem "hklm:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\"
        reg export "hklm\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" C:\temp\SSL_3.reg /y
    }
    else{
        Write-Warning "SSL 3.0 Registry is not available"
    }
    Write-Host "--------------------------------`n" -ForegroundColor Green
}

Function Get-TLS-V1.0{
    Write-Output "Get-TLS V1.0 $env:COMPUTERNAME"
    if(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\" )
    {
        Get-ChildItem "hklm:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\"
        reg export "hklm\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" C:\temp\TLS_1_0.reg /y
    }
    else{
        Write-Warning "TLS 1.0 Registry is not available"
    }
    Write-Host "--------------------------------`n" -ForegroundColor Green
}

Function Get-TLS-V1.1{
    Write-Output "Get-TLS V1.1 $env:COMPUTERNAME"
    if(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\" )
    {
        Get-ChildItem "hklm:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\"
        reg export "hklm\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" C:\temp\TLS_1_1.reg /y
    }
    else{
        Write-Warning "TLS 1.1 Registry is not available"
    }
    Write-Host "--------------------------------`n" -ForegroundColor Green
}

Function Get-TLS-V1.2{
    Write-Output "`n Get-TLS V1.2 $env:COMPUTERNAME"
    if(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\" )
    {
        Get-ChildItem "hklm:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\"
        reg export "hklm\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" C:\temp\TLS_1_2.reg /y
    }
    else{
        Write-Warning "TLS 1.2 Registry is not available"
    }
    Write-Host "--------------------------------`n`n" -ForegroundColor Green
}



Get-StrongCrypto
Get-SSLV2.0
Get-SSLV3.0
Get-TLS-V1.0
Get-TLS-V1.1
Get-TLS-V1.2
