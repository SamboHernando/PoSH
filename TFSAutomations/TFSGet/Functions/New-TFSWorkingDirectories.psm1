function New-TFSWorkingDirectories {
    
        param(
            # Parameter help description
            [Parameter()]
            [string]
            $ControlDir = "$PWD\TFS-Items",

            # Parameter help description
            [Parameter()]
            [string]
            $tfsChangeSetFile = "$PWD\TFSItemChanges.csv"
            
            )
        <# Check to see if the TFS-Control directory has been created or not. The script will terminate if it needs to create the folder\file, 
        this will allow you to add the paths from the change log before proceeding #>
        
        Write-Host "`Checking for existing directories..." -NoNewline -ForegroundColor Cyan         
        
        if (Test-Path $controlDir) {
             
            Write-Host ((Split-Path -Leaf $controlDir) + " directory exists.") -ForegroundColor Cyan
        }
        else {
    
            Write-Host ("`nTFS Items directory does not exist, creating TFS-Items directory and TFSItemChanges.csv in the current directory") -ForegroundColor Yellow
                [void](New-Item -ItemType Directory -Path $controlDir)
			if (Test-Path $tfsChangeSetFile){} else{
                [void](New-Item -ItemType File -Path $tfsChangeSetFile)
                [void](Add-Content -Path $tfsChangeSetFile -Value "TFSItem,ChangeSet")
				}
            Write-Host ("`nSince this is your first time runnignt this script, you will need to edit the TFSItemChanges.csv and add the correct paths and optionally the `
				changeset supplied in the change log. Press enter to stop this script and edit the TFSItemChanges.csv`n") -ForegroundColor Yellow
        
            pause
            Invoke-Item -Path $tfsChangeSetFile
            exit
        }
    
        Write-Host "`Checking for existing file..." -NoNewline -ForegroundColor Cyan             
        
        if (Test-Path $tfsChangeSetFile) {
             
            Write-Host ($tfsChangeSetFile + " exists.") -ForegroundColor Cyan
        }
        else {
        
            Write-Host ("TFS Items text does not exitst, creating TFSItemChanges.csv in $controlDir") -ForegroundColor Yellow
                [void](New-Item -ItemType File -Path $tfsChangeSetFile)
                [void](Add-Content -Path $tfsChangeSetFile -Value "TFSItem,ChangeSet")
            Write-Host ("`nYou will need to edit the TFSItems.csv and add the correct paths and optionally the changeset supplied in the change log. Press enter to stop this script and `
            edit the TFSItems.txt`n") -ForegroundColor Yellow
        
            pause
            Invoke-Item -Path $tfsChangeSetFile
            exit
        }
        # Here we clear the content of our working directory to remove previous pulls
        Write-Host "Cleaning the directory before continuing..." -ForegroundColor Cyan -NoNewline
        Get-ChildItem $controlDir | Remove-Item -Recurse -Force
        Write-Host "cleaned." -ForegroundColor Cyan
    }