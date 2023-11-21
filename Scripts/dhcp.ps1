<#
    .SYNOPSIS
    Script for monitoring Windows DHCP servers.

    .DESCRIPTION
    Works only with PowerShell 3.0 and above.
    
    .EXAMPLE
    dhcp.ps1 lld
    [{"192.168.20.0":{"PercentageInUse":10,"Free":158,"Reserved":2,"InUse":18}]

    .EXAMPLE
    dhcp.ps1 full
    [{"192.168.20.0":{"PercentageInUse":10,"Free":158,"Reserved":2,"InUse":18}]
    
    .NOTES
    Author: DindonSama
    Github: https://github.com/DindonSama
    Github: https://github.com/Viennedoc
#>

Param (
    [Parameter(Position = 0, Mandatory = $False)][string]$action
)

if (Get-Command -Name Get-DhcpServerv4ScopeStatistics -ea 0) {
    $query = Get-DhcpServerv4ScopeStatistics
}
else {
    Write-Output 'No dhcp server on this machine'
    exit 1
}

function lld {
    $to_json = $null
    $to_json = @()
    foreach ($item in $query) {
        $Object = $null
        $Object = New-Object System.Object
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.SCOPEID}" -Value $item.ScopeId.IPAddressToString
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.FREE}" -Value $item.Free
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.INUSE}" -Value $item.InUse
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.PERCENTAGEINUSE}" -Value $item.PercentageInUse
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.RESERVED}" -Value $item.Reserved
    
        $query2 = Get-DhcpServerv4Scope -ScopeId $item.ScopeId
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.START}" -Value $query2.StartRange.IPAddressToString
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.END}" -Value $query2.EndRange.IPAddressToString
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.MASK}" -Value $query2.SubnetMask.IPAddressToString
        $Object | Add-Member -type NoteProperty -Name "{#DHCP.LEASEDURATION}" -Value $query2.LeaseDuration.TotalSeconds

        $to_json += $Object        
    }
    return ConvertTo-Json -Compress -InputObject @($to_json)
}

function full {
    $query | foreach-object {
        $query2 = Get-DhcpServerv4Scope -ScopeId $_.ScopeId
        $data = [psobject]@{"Free"            = [int]$_.Free;
                            "InUse"           = [int]$_.InUse;
                            "PercentageInUse" = [int]$_.PercentageInUse;
                            "Reserved"        = [int]$_.Reserved;
                            "RangeStart"      = [string]$query2.StartRange.IPAddressToString;
                            "RangeEnd"        = [string]$query2.EndRange.IPAddressToString;
                            "RangeMask"       = [string]$query2.SubnetMask.IPAddressToString;
                            "LeaseDuration"   = [int]$query2.LeaseDuration.TotalSeconds
        }
        $to_json += @{[string]$_.ScopeId = $data }
    }
    return ConvertTo-Json $to_json -Compress
}

switch ($action) {
    "lld" {
        return $(lld)
    }
    "full" {
        return $(full)
    }
    Default { 
        Write-Host "Syntax error: Use 'lld' or 'full' as first argument" 
        exit 1
    }
}