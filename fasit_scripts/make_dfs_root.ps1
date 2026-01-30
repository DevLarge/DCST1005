Invoke-Command -ComputerName srv1 -ScriptBlock {
    New-Item -Path "C:\dfsroots" -ItemType Directory -Force
    New-Item -Path "C:\shares" -ItemType Directory -Force
    
    # Create department folders
    $departments = @('Finance','Sales','IT','Consultants','HR')
    foreach ($dept in $departments) {
        New-Item -Path "C:\shares\$dept" -ItemType Directory -Force
    }
    
    # Create files folder under dfsroots
    New-Item -Path "C:\dfsroots\files" -ItemType Directory -Force
}