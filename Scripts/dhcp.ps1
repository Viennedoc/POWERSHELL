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
    
        $to_json += $Object        
    }

    return ConvertTo-Json -Compress -InputObject @($to_json)
}

function full {
    $query | foreach-object {
        $data = [psobject]@{"Free"            = [int]$_.Free;
                            "InUse"           = [int]$_.InUse;
                            "PercentageInUse" = [int]$_.PercentageInUse;
                            "Reserved"        = [int]$_.Reserved
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