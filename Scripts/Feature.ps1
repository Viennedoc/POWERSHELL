<#
    .SYNOPSIS
    Script for autodiscover feature for Windows servers.

    .DESCRIPTION
    Works only with Windows Serveur PowerShell 3.0 and above.
    
    .EXAMPLE
    Feature.ps1 
    Viennedoc:59d6e27314eed30d17e98a9d4cbdafdc1465e41a

    .NOTES
    Author: DindonSama
    Github: https://github.com/DindonSama
    Github: https://github.com/Viennedoc
#>

Param (
    [Parameter(Position = 0, Mandatory = $False)][string]$Feature
)

function Function_Feature {
    $query = Get-WindowsFeature | Where-Object { ($_.InstallState -EQ "Installed") -and ($_.Name -EQ $Feature) } | Select-Object Name 
    return ConvertTo-Json $query -Compress
}
function Function_ALL_Feature {
    $Feature = @('DHCP', 'Hyper-V', 'AD-domain-services')
    $result = $null
    $result = @()
    foreach ($i in $Feature) {
        switch ($i) {
            "DHCP" {
                if (!(Get-Command -Name Get-DhcpServerv4ScopeStatistics -ea 0)) {
                    break
                }
                $temp_DHCP = ConvertFrom-Json -InputObject $(& 'C:\Program Files\Zabbix Agent 2\scripts\dhcp.ps1' full)
                $temp_DHCP = @{$i = $temp_DHCP }
                $result += $temp_DHCP
            }
            "Hyper-V" {
                if (!(Get-Command -Name Get-VM -ea 0)) {
                    break
                }
                $temp_HYPERV = ConvertFrom-Json -InputObject $(& 'C:\Program Files\Zabbix Agent 2\scripts\hyperv.ps1' full)
                $temp_HYPERV = @{HYPERV = $temp_HYPERV }
                $result += $temp_HYPERV
            }
            "AD-domain-services" {
                if (!(Get-Command -Name Get-ADDomain -ea 0)) {
                    break
                }
                $temp_AD = ConvertFrom-Json -InputObject $(& 'C:\Program Files\Zabbix Agent 2\scripts\AD.ps1' full)
                $temp_AD = @{AD = $temp_AD }
                $result += $temp_AD
            }
            Default {}
        }
    }
    $post_result = ConvertTo-Json @($result) -depth 5 -Compress
    return $post_result
}

if ($Feature) {
    Write-Host $(Function_Feature)
}
else {
    Write-Host $(Function_ALL_Feature)
}
