Invoke-Command -ComputerName srv1 -ScriptBlock {
    # Verify DFS root
    Get-DfsnRoot -Path "\\infrait.sec\files"

    # Verify DFS folders
    Get-DfsnFolder -Path "\\infrait.sec\files\*" | 
    Format-Table Path,TargetPath,State -AutoSize
}