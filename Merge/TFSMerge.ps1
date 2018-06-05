function Import-TFSItemCSV {
    
    param(
        # Parameter help description
        [Parameter()]
        [string]
        [Alias('Path')]
        $tfsChangeSetFile = "$PWD\TFSItemChanges.csv"
        )
    # Load the content of the text file that contains all the TFS items we desire
    $tfsItems = Import-Csv -Path $tfsChangeSetFile | Where-Object {$_.PSObject.Properties.Value -ne "$null"}
    
    return $tfsItems
    
}

# Import the contents of the $sourceFile, test the path, if it does not exist, create it
$sourceFile = ".\MergeTargets.csv"
$pathTest = Test-Path -Path $SourceFile
if ($pathTest -eq $false){

    [void](New-Item -ItemType File -Path $sourceFile)
    [void](Add-Content -Path $sourceFile -Value "TFSItem,ChangeSet")
    Write-Host "A text file containing the list of merge candidates could not be found. One has been created for you in your current directory. Please add candidates to this file and try agian. File name: $SourceFile " -ForegroundColor Yellow

    Pause
    Exit
}

# Search for the correct dll so we can import the namespace to do all the heavy lifting
$tfsExeLoc = Get-Item "C:\Program Files (x86)\Microsoft Visual Studio*\"
Write-Host "Attempting to load assemblies..." -NoNewline -ForegroundColor Cyan

try {
    [void][Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
    Write-Host "assemblies found and loaded" -ForegroundColor Cyan
}
catch {
    Write-Host "searching for assemblies..." -NoNewline -ForegroundColor Cyan
    foreach ($path in $tfsExeLoc){
        $tfsdll = Get-ChildItem $path -Recurse -Include "Microsoft.TeamFoundation.VersionControl.Client.dll"
        if ($tfsdll){
            Add-Type -Path $tfsdll[0].FullName
            Write-Host "assemblies found and loaded" -ForegroundColor Cyan
            break
        }
    }
}

# Here we define the TFS URL and create the collection object and version control objects
$tfsCollectionUrl = 'REPLACE_WITH_TFS_URL'
$tfsCollection = New-Object -TypeName Microsoft.TeamFoundation.Client.TfsTeamProjectCollection -ArgumentList $tfsCollectionUrl
$tfsVersionControl = $tfsCollection.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer])
		
# Here we attemp to use an existing workspace or create a new one if one is not found   

try{
    $workspace = $tfsVersionControl.GetWorkspace("Auto_Merge", $Env:USERNAME)
    }
catch {
    $templocaldir = "$env:USERPROFILE\Source\Workspaces\" + [GUID]::NewGuid().ToString()
    New-Item $templocaldir -Type Directory -Force
    $workspace = $tfsVersionControl.CreateWorkspace("Auto_Merge")
    $workspace.Map("$\",$tempLocaldir)
}

#$tfsitems = "Get-Content $SourceFile"
Write-Host  "Importing items from CSV..." -ForegroundColor Cyan -NoNewline
$tfsItems = Import-TFSItemCSV $sourceFile
Write-Host "$($tfsItems.Count) items imported." -ForegroundColor Cyan

$missingItems = $null

#This block will need to be its own function to allow the testing of the paths before we run through the rest of the script, Test-TFSItemPath
Write-Host "Checking the item paths against the server..." -ForegroundColor Cyan -NoNewline
foreach ($item in $tfsItems) {
    if($tfsVersionControl.ServerItemExists(
        $item.TFSItem,
        [Microsoft.TeamFoundation.VersionControl.Client.ChangesetVersionSpec]::new($item.ChangeSet),
        [Microsoft.TeamFoundation.VersionControl.Client.DeletedState]::NonDeleted,
        [Microsoft.TeamFoundation.VersionControl.Client.ItemType]::File))
        {}
    else{
        [array]$missingItems += "$($item.TFSItem)--$($item.ChangeSet)"
    }
}

if ($missingItems -ne $null){
    Write-Host "`nThe following items could not be found on the server, please check the path and version and try again:" -ForegroundColor Yellow
    foreach ($item in $missingItems) {
        Write-Host $item -ForegroundColor Yellow
    }
    Pause
    Exit
}
else {
    Write-Host "all $($tfsItems.Count) items found" -ForegroundColor Cyan
    foreach ($item in $tfsItems){

        $itemspec = New-Object -TypeName Microsoft.TeamFoundation.VersionControl.Client.ItemSpec -ArgumentList $item.TFSItem,None
        $versionSpec = New-Object -TypeName Microsoft.TeamFoundation.VersionControl.Client.ChangesetVersionSpec -ArgumentList $item.ChangeSet
        
        $item = $item.TFSItem.Replace("\","/")
        $targetPath = $item.Replace("/Main/","/Release/")
        $candidate = $tfsVersionControl.GetMergeCandidates($itemspec, $targetPath)
        
        $candidate.Changeset | 
        Where-Object {$_.ChangesetId -EQ $versionSpec.ChangesetId} | 
        Select-Object (@{Name="ItemSource";Expression={$item}}),(@{Name="Destination";Expression={$targetPath}}),ChangesetID,Owner,CreationDate,Comment

        #For this merge we want to pass the changeset as a perameter in the argument to allow us to merge a specific version
        $getStatus = $workspace.Merge($item,$targetPath,$versionSpec,$null)

        if ($getStatus.NumConflicts -gt 0){
            $conflicts += $workspace.QueryConflicts(@($item,$targetPath),$true)
            Write-Host "A conflicts was found during the merge operation for the above item. Please make sure to review the conflict in VS before checking your changes in."`n -ForegroundColor Yellow
        }
        elseif ($getStatus.NumFailures -gt 0) {
            $failures += $getStatus.GetFailures()
            Write-Host "$($getStatus.GetFailures().Message)`n" -ForegroundColor Yellow
        }
    }
    $pendingChanges = $workspace.GetPendingChanges()
    Write-Host "Finshed, $($pendingChanges.Count)\$($tfsItems.Count) items pending checkin, $($conflicts.Count) conflicts detected, $($failures.Count) failures." -ForegroundColor Cyan
    Write-Host "Please use the `"Auto-Merge`" workspace in Visual Studio to review and check in your merge.`n" -ForegroundColor Cyan
}

pause