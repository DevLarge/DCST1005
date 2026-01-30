Invoke-Command -ComputerName srv1 -ScriptBlock {
    # Configure NTFS permissions for each department
    $folderPermissions = @{
        'HR' = 'l_fullAccess-hr-share'
        'IT' = 'l_fullAccess-it-share'
        'Sales' = 'l_fullAccess-sales-share'
        'Finance' = 'l_fullAccess-finance-share'
        'Consultants' = 'l_fullAccess-consultants-share'
    }

    foreach ($folder in $folderPermissions.Keys) {
        $path = "C:\shares\$folder"
        $group = $folderPermissions[$folder]

        # Create new ACL
        $acl = New-Object System.Security.AccessControl.DirectorySecurity

        # Disable inheritance and remove inherited permissions
        $acl.SetAccessRuleProtection($true, $false)
        
        # Create and add the rules
        $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $groupRule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

        $acl.AddAccessRule($adminRule)
        $acl.AddAccessRule($systemRule)
        $acl.AddAccessRule($groupRule)

        # Apply the new ACL
        Set-Acl -Path $path -AclObject $acl
        Write-Host "Permissions set for $folder"
    }

    # Configure DFS root with same approach
    $dfsPath = "C:\dfsroots\files"
    $dfsAcl = New-Object System.Security.AccessControl.DirectorySecurity
    $dfsAcl.SetAccessRuleProtection($true, $false)

    # Add base permissions
    $dfsAcl.AddAccessRule($adminRule)
    $dfsAcl.AddAccessRule($systemRule)

    # Add all department groups
    foreach ($group in $folderPermissions.Values) {
        $groupRule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $dfsAcl.AddAccessRule($groupRule)
    }

    Set-Acl -Path $dfsPath -AclObject $dfsAcl
    Write-Host "Permissions set for DFS root"
}