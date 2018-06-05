function Update-Binaries  {
    
    param(

    # Parameter help description
    [Parameter()]
    [string]
    $SourceBin,

    # Parameter help description
    [Parameter()]
    [array]
    $DestinationBin
    
    )
        try{ 
            $sourceItems = Get-ChildItem -Path $sourceBin -Recurse -ErrorAction Stop | Where-Object {$_.PSISContainer -EQ $False}
        }
        catch [System.Management.Automation.ItemNotFoundException]{
            Write-Host $Error[0].Exception.Message -ForegroundColor Yellow
        }
        foreach ($destination in $DestinationBin){
    
            foreach ($item in $sourceItems){
                
                $destinationItem = $item.FullName.Replace($sourceBin,$destination)
                $destinationFolder = (Split-Path $destinationItem)

                    if (Test-Path $destinationFolder){
                        Write-Host "Copying $($item.Name) to $destinationFolder`n" -ForegroundColor Cyan
                        Copy-Item -Path $item.FullName -Destination $destinationFolder -Force
                    }
                    else {
                        Write-Host "Creating parent directories and copying $($item.Name) to $destinationFolder`n" -ForegroundColor Cyan
                        New-Item -Path $destinationFolder -ItemType Directory -Force
                        Copy-Item -Path $item.FullName -Destination $destinationFolder -Force
                    }
                }
            }
        }