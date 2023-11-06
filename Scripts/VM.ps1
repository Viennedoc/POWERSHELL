<#
    .SYNOPSIS
    Script to display hyperv server name if it's a virtual machine

    .DESCRIPTION
    Works only with PowerShell 3.0 and above.
    
    .EXAMPLE
    VM.ps1
    HYPERV1

    .EXAMPLE
    VM.ps1
    Machine Physique
    
    .NOTES
    Author: DindonSama
    Github: https://github.com/DindonSama
    Github: https://github.com/Viennedoc
#>


if (Test-Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters") {
    Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters"  | Select-Object -ExpandProperty HostName
} else {
    Write-Host "Machine Physique"
}