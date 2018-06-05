function Backup-Binaries  {
    
    param(

    # Parameter help description
    [Parameter()]
    [string]
    $SourceBin,

    # Parameter help description
    [Parameter()]
    [array]
    $DestinationBin,

    # Parameter help description
    [Parameter()]
    [string]
    $Backups = "C:\backups\$(Get-Date -Format MMddyyyy_hhmmss)\"
    )

    try{ 
        $sourceItems = Get-ChildItem -Path $sourceBin -Recurse -ErrorAction Stop | Where-Object {$_.PSISContainer -EQ $False}
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        Write-Host $Error[0].Exception.Message -ForegroundColor Yellow
    }
    
    if (Test-Path $Backups){}
    else {
        Write-Host "`nCreating backup directory $Backups`n" -ForegroundColor Cyan
        [void](New-Item $Backups -ItemType Directory -Force)
    }

    
    foreach ($destination in $DestinationBin){

        foreach ($item in $sourceItems){
            
            $destinationItem = $item.FullName.Replace($sourceBin,$destination)
            $pathCheck = Test-Path $destinationItem
            $BackupsItem =  $destinationItem.Replace((Split-Path $destination), $Backups)
        
            if ($pathCheck){
				if ($item.LastWriteTime -ne $destinationItem.LastWriteTime){
            Write-Host "Backing up $destinationItem to $BackupsItem`n" -ForegroundColor Cyan
            [void](New-Item -Path (Split-Path $BackupsItem) -ItemType Directory -Force)
            [void](Copy-Item $destinationItem -Destination $BackupsItem -Force -Container)
					}
            }
        }             
    }          
}