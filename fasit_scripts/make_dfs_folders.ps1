Invoke-Command -ComputerName srv1 -ScriptBlock {
    # Create DFS folders for each department
    $departments = @('Finance','Sales','IT','Consultants','HR')
    foreach ($dept in $departments) {
        New-DfsnFolder -Path "\\infrait.sec\files\$dept" `
                      -TargetPath "\\srv1\$dept" `
                      -EnableTargetFailback $true
    }
}