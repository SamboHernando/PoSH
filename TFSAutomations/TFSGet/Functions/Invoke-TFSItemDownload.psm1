#THese are the main parameters, items will be supplied by the tfsItemChanges param so it is redundant
function Invoke-TFSItemDownload {

    param (
        # Parameter help description
        [Parameter()]
        [array]
        $tfsItemsChanges = (Import-TFSItemCSV),

        # Parameter help description
        [Parameter()]
        [String]
        $drop = "$PWD\TFS-Items"
    )

    foreach ($change in $tfsItemsChanges) {

        $item = $change.TFSItem
        $changeSet = $null
        $itemDrop = $drop + $item.Replace("$","")

        $dropTest = Test-Path $(Split-Path $itemDrop)
        if ($dropTest){}
        else {
            [void](New-Item -ItemType Directory -Path $(Split-Path $itemDrop))
        }


        # Set the value of version and changeSet for the Rest parameters later as well as the changing changeset to latest for null values
        if ($change.ChangeSet -like $null -or $change.ChangeSet -like " "){
            $version = "versionType=Latest"
            $changeSet = "Latest"
            }
            else {
            $changeSet = $change.ChangeSet
            $version = "versionType=Changeset&version=$changeSet"
            }

            $itemData = Invoke-RestMethod `
                                -Method Get `
                                -Uri "REPLACE_WITH_TFS_URL/_apis/tfvc/items?scopePath=$item&$version" `
                                -UseDefaultCredentials
                
                Write-Host "`nPulling $item - $changeSet to $drop..." -NoNewline -ForegroundColor Cyan

                if ($itemData.value[0].isFolder -eq $true){
                    try{
                        
                        $itemDrop = ($itemDrop + ".zip")

                        Invoke-RestMethod `
                            -Method Get `
                            -Uri "REPLACE_WITH_TFS_URL/_apis/tfvc/items/$item/?$version" `
                            -UseDefaultCredentials `
                            -Headers @{Accept = "application/zip"} `
                            -OutFile $itemDrop                   
    
                        Write-Host "item downloaded" -ForegroundColor Cyan
                    }
                    catch{
                        Write-Host ("`nThe file $item does not exist or has been removed, please check the path and try again.") -ForegroundColor Red                             
                    }
                }
                else{
                    try{
                        Invoke-RestMethod `
                            -Method Get `
                            -Uri "REPLACE_WITH_TFS_URL/_apis/tfvc/items/$item/?$version" `
                            -UseDefaultCredentials `
                            -OutFile $itemDrop
                        
                        (Get-Item $itemDrop).LastWriteTime = $itemData.value.changeDate
    
                        Write-Host "item downloaded" -ForegroundColor Cyan
                    }
                    catch{
                        Write-Host ("`nThe file $item does not exist or has been removed, please check the path and try again.") -ForegroundColor Red                             
                    }
                }
            }
        }