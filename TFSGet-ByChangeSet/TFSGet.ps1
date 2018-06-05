param (
# Parameter help description
[Parameter(Mandatory=$true)]
[int]
$ChangeSet,

# Parameter help description
[Parameter(Mandatory=$true)]
[string]
$BuildDirectory

)
$functions = Get-ChildItem -Path .\Functions

foreach ($function in $functions){

    Import-Module $functions.FullName -Force
}

#With TFS build steps the following line may not be necessary
# New-TFSWorkingDirectories -ControlDir $controlDir

Invoke-TFSItemDownload -ChangeSet $ChangeSet -ControlDir $BuildDirectory