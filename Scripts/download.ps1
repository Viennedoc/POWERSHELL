$SCRIPT = @('AD','dhcp','download','Feature','hyperv')
$CONF = @('General')

[Net.ServicePointManager]::SecurityProtocol = [net.SecurityProtocolType]::Tls12

$response = Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/repos/DindonSama/POWERSHELL/commits/main"

if ($response.statuscode -eq '200') {

    if (!(Test-Path "C:\Program Files\Zabbix Agent 2\scripts")) {
        New-Item -ItemType Directory -Force -Path "C:\Program Files\Zabbix Agent 2\scripts"
    }
    foreach ($LOOP_SCRIPT in $SCRIPT) {
        Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/DindonSama/POWERSHELL/main/Scripts/$LOOP_SCRIPT.ps1" -OutFile "C:\Program Files\Zabbix Agent 2\scripts\$LOOP_SCRIPT.ps1"
    }

    if (!(Test-Path "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d")) {
        New-Item -ItemType Directory -Force -Path "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d"
    }
    
    foreach ($LOOP_CONF in $CONF) {
        $OHASH = $(Get-FileHash "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\$LOOP_CONF.conf").hash
        Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/DindonSama/POWERSHELL/main/zabbix_agent2.d/$LOOP_CONF.conf" -OutFile "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\$LOOP_CONF.conf"
        $DHASH = $(Get-FileHash "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\$LOOP_CONF.conf").hash
        if ($OHASH -ne $DHASH){
            $RESTART = 1
        }
    }
    if ($RESTART -eq '1') {
        Restart-Service "Zabbix Agent 2" -Force | Out-Null
    }
    $keyValue= ConvertFrom-Json $response.Content | Select-Object -expand "sha"
    Write-Output $keyValue
}
else {
    Write-Output "No Internet"
}