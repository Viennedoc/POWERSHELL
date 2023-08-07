Param (
    [Parameter(Position = 0, Mandatory = $False)][string]$action
)

if (Get-Command -Name Get-ADDomain -ea 0) {
    $query = Get-ADDomain
}
else {
    Write-Output 'No AD server on this machine'
    exit 1
}

function lld {
    $to_json = $null
    $to_json = @()
    
    foreach ($item in $query) {
        $Object = $null
        $Object = New-Object System.Object
        $Object | Add-Member -type NoteProperty -Name "{#AD.NAME}" -Value $item.Name
        $Object | Add-Member -type NoteProperty -Name "{#AD.FOREST}" -Value $item.Forest
        $Object | Add-Member -type NoteProperty -Name "{#AD.DOMAINMODE}" -Value $item.DomainMode
    
        $to_json += $Object        
    }

    return ConvertTo-Json -InputObject $to_json -Compress
}

function F1 {
    $to_json = $null
    $InactiveDays = 90
    $Days = (Get-Date).Adddays(-($InactiveDays))

    $ADUserInactifList = Get-ADUser -Filter {LastLogonTimeStamp -lt $Days -and enabled -eq $true} -Properties LastLogonTimeStamp | Sort-Object -Property LastLogonTimeStamp | select-object SamAccountName,Name,@{Name="Date"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('dd-MM-yyyy')}}
    
    $ADUserInactifList | foreach-object {
        $data = [psobject]@{"SamAccountName"        = [string]$_.SamAccountName;
                            "Name"                  = [string]$_.Name;
                            "Date"                  = [string]$_.Date
        }
        $to_json += @{[string]$_.SamAccountName = $data }
    }

    return ConvertTo-Json -InputObject $to_json -Compress
}
function F2 {
    $to_json = $null
    $InactiveDays = 90
    $Days = (Get-Date).Adddays(-($InactiveDays))

    $ADCInactifList = Get-ADcomputer -Filter 'lastLogondate -lt $Days' -properties Name,canonicalName,lastlogondate | Sort-Object -Property lastlogondate | Select-Object Name,canonicalname,lastlogondate
        
    $ADCInactifList | foreach-object {
        $data = [psobject]@{"name"            = [string]$_.name;
                            "canonicalname"   = [string]$_.canonicalname;
                            "lastlogondate"   = [string]$_.lastlogondate
        }
        $to_json += @{[string]$_.name = $data }
    }

    return ConvertTo-Json -InputObject $to_json -Compress
}

function full {
    $to_json = $null

    $query | foreach-object {
        $data = [psobject]@{"DomainMode"      = [string]$_.DomainMode;
                            "Forest"          = [string]$_.Forest;
                            "Name"            = [string]$_.Name
        }
        $to_json += @{[string]$_.Forest = $data }
    }

    $temp_F1 = ConvertFrom-Json -InputObject $(F1)
    $to_json += @{ADUserInactif = $temp_F1 }
    $temp_F2 = ConvertFrom-Json -InputObject $(F2)
    $to_json += @{ADComputerInactif = $temp_F2 }

    return ConvertTo-Json -InputObject $to_json -Compress
}

switch ($action) {
    "lld" {
        return $(lld)
    }
    "full" {
        return $(full)
    }
    "aduserinactif" {
        return $(F1)
    }
    Default { 
        Write-Host "Syntax error: Use 'lld' or 'full' or 'aduserinactif' as first argument" 
        exit 1
    }
}