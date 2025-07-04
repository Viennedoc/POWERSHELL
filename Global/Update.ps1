<#
    .SYNOPSIS
    Script for Update Zabbix agent.

    .DESCRIPTION
    Nothing special.
    
    .NOTES
    Author: DindonSama
    Github: https://github.com/DindonSama
    Github: https://github.com/Viennedoc
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
$a=(Select-String -Pattern '^Server=' -Path 'C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf').line
$b=(Select-String -Pattern '^ServerActive=' -Path 'C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf').line
$c=(Select-String -Pattern '^Hostname=' -Path 'C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf').line
$d=(Select-String -Pattern '^HostMetadata=' -Path 'C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf').line
$v=(Select-String -Pattern '^TLSPSKIdentity=' -Path 'C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf').line
$e="$a`n$b`n$c`n$d`nForceActiveChecksOnStart=1`nLogFile=C:\Program Files\Zabbix Agent 2\zabbix_agent2.log`nTimeout=30`nInclude=C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\`nControlSocket=\\.\pipe\agent.sock`nTLSConnect=psk`nTLSAccept=psk`n`n$v`nTLSPSKFile=C:\Program Files\Zabbix Agent 2\psk.key`nAllowKey=system.run[*]`nInclude=.\zabbix_agent2.d\plugins.d\*.conf`n"
Out-File -Encoding ASCII -InputObject $e -FilePath 'C:\Program Files\Zabbix Agent 2\zabbix_agent2_new.conf'

Copy-Item -force -Path 'C:\Program Files\Zabbix Agent 2\zabbix_agent2_new.conf' -Destination 'C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf'

#Invoke-WebRequest 'https://cdn.zabbix.com/zabbix/binaries/stable/6.4/6.4.12/zabbix_agent2-6.4.12-windows-amd64-openssl.msi' -OutFile 'C:\Program Files\Zabbix Agent 2\zabbix_agent2-X.X.X-windows-amd64-openssl.msi'

#Invoke-WebRequest 'https://cdn.zabbix.com/zabbix/binaries/stable/7.2/latest/zabbix_agent2-7.2-latest-windows-amd64-openssl.msi' -OutFile 'C:\Program Files\Zabbix Agent 2\zabbix_agent2-X.X.X-windows-amd64-openssl.msi'
Invoke-WebRequest 'https://cdn.zabbix.com/zabbix/binaries/stable/7.4/latest/zabbix_agent2-7.4-latest-windows-amd64-openssl.msi' -OutFile 'C:\Program Files\Zabbix Agent 2\zabbix_agent2-X.X.X-windows-amd64-openssl.msi'

#msiexec.exe /i 'C:\Program Files\Zabbix Agent 2\zabbix_agent2-X.X.X-windows-amd64-openssl.msi' /log 'C:\Program Files\Zabbix Agent 2\zabbix_agent_install.log' /quiet
Start-Process -FilePath 'C:\Program Files\Zabbix Agent 2\zabbix_agent2-X.X.X-windows-amd64-openssl.msi' -ArgumentList "/qn $a $b $c" -wait

Start-Sleep 10

Copy-Item -force -Path 'C:\Program Files\Zabbix Agent 2\zabbix_agent2_new.conf' -Destination 'C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf'

Start-Sleep 10
Restart-Service -Name 'Zabbix Agent 2'
Remove-Item 'C:\Program Files\Zabbix Agent 2\zabbix_agent2-X.X.X-windows-amd64-openssl.msi'
Remove-Item 'C:\Program Files\Zabbix Agent 2\zabbix_agent_install.txt'
Unregister-ScheduledTask -TaskName "ZABBIXUP" -Confirm:$False
Remove-Item 'C:\Zabbix_Update.ps1'
