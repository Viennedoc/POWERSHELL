Param (
    [Parameter(Position = 0, Mandatory = $False)][string]$Feature
)

function Function_Feature {
    $query = Get-WindowsFeature | Where-Object { ($_.InstallState -EQ "Installed") -and ($_.Name -EQ $Feature) } | Select-Object Name 
    return ConvertTo-Json $query -Compress
}
function Function_ALL_Feature {
    $Feature = @('DHCP', 'Hyper-V', 'AD-domain-services')
    $query = $(Get-WindowsFeature | Where-Object { ($_.InstallState -EQ "Installed") } | Select-Object Name)
    $result = $null
    $result = @()
    foreach ($i in $Feature) {
        if ($query.Name -EQ $i) {
            switch ($i) {
                "DHCP" {
                    $temp_DHCP = ConvertFrom-Json -InputObject $(& 'C:\Program Files\Zabbix Agent 2\scripts\dhcp.ps1' full)
                    $temp_DHCP = @{$i = $temp_DHCP }
                    $result += $temp_DHCP
                }
                "Hyper-V" {
                    $temp_HYPERV = ConvertFrom-Json -InputObject $(& 'C:\Program Files\Zabbix Agent 2\scripts\hyperv.ps1' full)
                    $temp_HYPERV = @{HYPERV = $temp_HYPERV }
                    $result += $temp_HYPERV
                }
                "AD-domain-services" {
                    $temp_AD = ConvertFrom-Json -InputObject $(& 'C:\Program Files\Zabbix Agent 2\scripts\AD.ps1' full)
                    $temp_AD = @{AD = $temp_AD }
                    $result += $temp_AD
                }
                Default {}
            }
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
