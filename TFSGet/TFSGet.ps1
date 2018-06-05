$functions = Get-ChildItem -Path .\Functions

foreach ($function in $functions){

    Import-Module $functions.FullName -Force
}

$controlDir = "$PWD\TFS-Items"
$tfsFile = "$PWD\TFSItemChanges.csv"

New-TFSWorkingDirectories -ControlDir $controlDir -tfsChangeSetFile $tfsFile
Invoke-TFSItemDownload

pause
Invoke-Item $controlDir