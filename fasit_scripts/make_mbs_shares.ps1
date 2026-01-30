Invoke-Command -ComputerName srv1 -ScriptBlock {
    # Share department folders
    $departments = @('Finance','Sales','IT','Consultants','HR')
    foreach ($dept in $departments) {
        New-SmbShare -Name $dept -Path "C:\shares\$dept" -FullAccess "Everyone"
    }
    
    # Share DFS root folder
    New-SmbShare -Name "files" -Path "C:\dfsroots\files" -FullAccess "Everyone"
}