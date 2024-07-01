<#
    .SYNOPSIS
    Script for restart Zabbix agent.

    .DESCRIPTION
    Nothing special.
    
    .NOTES
    Author: DindonSama
    Github: https://github.com/DindonSama
    Github: https://github.com/Viennedoc
#>

Restart-Service -Name 'Zabbix Agent 2'

Unregister-ScheduledTask -TaskName "ZABBIX_RESTART" -Confirm:$False

Remove-Item 'C:\Zabbix_Restart.ps1'