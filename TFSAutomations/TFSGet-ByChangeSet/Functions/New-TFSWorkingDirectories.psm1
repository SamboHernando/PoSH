function New-TFSWorkingDirectories {
    
        param(
            # Parameter help description
            [Parameter()]
            [string]
            $controlDir = "$PWD\TFS-Items"

            )
        <# Check to see if the TFS-Control directory has been created or not. The script will terminate if it needs to create the folder\file, 
        this will allow you to add the paths from the change log before proceeding #>
        
        Write-Host "`Checking for existing directories..." -NoNewline -ForegroundColor Cyan         
        
        if (Test-Path $controlDir) {
             
            Write-Host ((Split-Path -Leaf $controlDir) + " directory exists.") -ForegroundColor Cyan
        }
        else {
    
            Write-Host ("`nTFS Items directory does not exist, creating TFS-Items directory in the current directory") -ForegroundColor Yellow
                [void](New-Item -ItemType Directory -Path $controlDir)
        }

        # Here we clear the content of our working directory to remove previous pulls
        Write-Host "Cleaning the directory before continuing..." -ForegroundColor Cyan -NoNewline
        Get-ChildItem $controlDir | Remove-Item -Recurse -Force
        Write-Host "cleaned." -ForegroundColor Cyan
    }