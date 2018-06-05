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