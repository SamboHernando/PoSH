param (
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    $storagePath
)

if(Test-Path $storagePath){
    Remove-Item -Path "$storagePath\*" -Recurse
}
else {
    New-Item -Path $storagePath -ItemType Directory
}

$ErrorActionPreference = "Stop"
$vms = Get-VM
foreach ($vm in $vms){
    try {
        Export-VM $vm -Path $storagePath
    }
    catch {
        Write-Error $Error[0].Message
    }
}