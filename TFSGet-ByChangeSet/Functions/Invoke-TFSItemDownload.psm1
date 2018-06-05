#THese are the main parameters, items will be supplied by the tfsItemChanges param so it is redundant
function Invoke-TFSItemDownload {

    param (
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [alias("ChangeSet")]
        [array]
        $tfsItemsChangeSet,

        # Parameter help description
        [Parameter()]
        [String]
        $drop = "$PWD\TFS-Items",

        # Parameter help description
        [Parameter()]
        [uri]
        $ConnectionUri = "REPLACE_WITH_TFS_URL"
    )

    $tfsChangeSetChanges = Invoke-RestMethod `
                        -Method Get `
                        -Uri "$ConnectionUri/_apis/tfvc/changesets/$tfsItemsChangeSet/changes" `
                        -UseDefaultCredentials

    foreach ($change in $tfsChangeSetChanges.value) {
        $itemPath = $change.item.path
        $itemUrl = $change.item.url
        $itemDrop = $drop + $itemPath.Replace("$","")

        $dropTest = Test-Path $(Split-Path $itemDrop)
        if ($dropTest){}
        else {
            [void](New-Item -ItemType Directory -Path $(Split-Path $itemDrop))
        }
            $itemData = Invoke-RestMethod `
                                -Method Get `
                                -Uri "$ConnectionUri/_apis/tfvc/items?scopePath=$itemPath" `
                                -UseDefaultCredentials
                
                Write-Host "`nPulling $itemPath to $itemDrop..." -NoNewline -ForegroundColor Cyan

                try{
                    Invoke-RestMethod `
                        -Method Get `
                        -Uri $itemUrl `
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