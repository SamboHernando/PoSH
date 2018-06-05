param (

# Parameter help description
[Parameter(Mandatory="True")]
[Alias("SourceBin")]
[string]
$Source,

# Parameter help description
[Parameter(Mandatory="True")]
[Alias("DestinationBin")]
[array]
$Destination,

# Parameter help description
[Parameter()]
[switch]$RemoveConfigFiles,
[string]$ConfigName = "w*.config"

)

$scriptDirectory = Split-Path $MyInvocation.MyCommand.Path

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs

exit 
    
}

Set-Location $scriptDirectory

$functions = Get-ChildItem -Path .\Functions

foreach ($function in $functions){

    Import-Module $function.FullName
}

Backup-Binaries -SourceBin $Source -DestinationBin $Destination -ErrorAction SilentlyContinue

if ($RemoveConfigFiles){
    Get-ChildItem $Source -Filter $ConfigName | Remove-Item
}

Update-Binaries -SourceBin $Source -DestinationBin $Destination -ErrorAction SilentlyContinue
