<#
    .SYNOPSIS
    Script for monitoring Hyper-V servers.

    .DESCRIPTION
    Provides LLD for Virtual Machines on the server and
    can retrieve JSON with found VMs parameters for dependent items.

    Works only with PowerShell 3.0 and above.
    
    .PARAMETER action
    What we want to do - make LLD or get full JSON with metrics.

    .PARAMETER version
    Print verion number and exit.

    .EXAMPLE
    hyperv.ps1 lld
    {"data":[{"{#VM.NAME}":"Windows 10 MSIX packaging environment","{#VM.VERSION}":"11.0","{#VM.CLUSTERED}":0,"{#VM.HOST}":"SERVEUR","{#VM.GEN}":2,"{#VM.ISREPLICA}":0,"{#VM.NOTES}":""}]}

    .EXAMPLE
    hyperv.ps1 full
    {"Windows 10 MSIX packaging environment":{"NumaSockets":1,"ReplMode":0,"CritErrAction":1,"IntSvcState":2,"ReplHealth":0,"State":3,"ReplState":0,"NumaNodes":1,"CPUUsage":0,"IntSvcVer":"0.0","StartAction":3,"IsClustered":0,"Uptime":0,"Memory":0,"StopAction":3}}
    
    .NOTES
    Author: Dindon_Sama
    Github: https://github.com/DindonSama
#>

Param (
    [switch]$version = $False,
    [Parameter(Position=0,Mandatory=$False)][string]$action
)

if (!(Get-Command -Name Get-VM -ea 0)) {
    Write-Output 'No HyperV server on this machine'
    exit 1
}

# Low-Level Discovery function
function Make-LLD() {
    $vms = Get-VM | Select-Object @{Name = "{#VM.NAME}"; e={$_.VMName}},
                                  @{Name = "{#VM.VERSION}"; e={$_.Version}},
                                  @{Name = "{#VM.CLUSTERED}"; e={[int]$_.IsClustered}},
                                  @{Name = "{#VM.HOST}"; e={$_.ComputerName}},
                                  @{Name = "{#VM.GEN}"; e={$_.Generation}},
                                  @{Name = "{#VM.ISREPLICA}"; e={[int]$_.ReplicationMode}},
                                  @{Name = "{#VM.NOTES}"; e={$_.Notes}}
    return ConvertTo-Json @{"data" = [array]$vms} -Compress
}

# JSON for dependent items
function Get-FullJSON() {
    $to_json = @{}
    
    # Because of IntegrationServicesState is string, I've made a dict to map it to int (better for Zabbix):
    # 0 - Up to date
    # 1 - Update required
    # 2 - unknown state
    $integrationSvcState = @{
        "Up to date" = 0;
        "Update required" = 1;
        "" = 2
    }

    Get-VM | ForEach-Object {
        $vm_data = [psobject]@{"State" = [int]$_.State;
                               "Uptime" = [math]::Round($_.Uptime.TotalSeconds);
                               "NumaNodes" = $_.NumaNodesCount;
                               "NumaSockets" = $_.NumaSocketCount;
                               "IntSvcVer" = [string]$_.IntegrationServicesVersion;
                               "IntSvcState" = $integrationSvcState[$_.IntegrationServicesState];
                               "CPUUsage" = $_.CPUUsage;
                               "Memory" = $_.MemoryAssigned;
                               "ReplMode" = [int]$_.ReplicationMode;
                               "ReplState" = [int]$_.ReplicationState;
                               "ReplHealth" = [int]$_.ReplicationHealth;
                               "StopAction" = [int]$_.AutomaticStopAction;
                               "StartAction" = [int]$_.AutomaticStartAction;
                               "CritErrAction" = [int]$_.AutomaticCriticalErrorAction;
                               "IsClustered" = [int]$_.IsClustered
                               }
        $to_json += @{$_.VMName = $vm_data}
    }
    return ConvertTo-Json $to_json -Compress
}

# Main switch
switch ($action) {
    "lld" {
        return $(Make-LLD)
    }
    "full" {
        return $(Get-FullJSON)
    }
    Default {Write-Host "Syntax error: Use 'lld' or 'full' as first argument"}
}
