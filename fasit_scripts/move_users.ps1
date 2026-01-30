Import-Module ActiveDirectory

# Base OU where department OUs should live
$BaseOU = "OU=InfraIT_Users,DC=infrait,DC=sec"

# Allowed departments
$AllowedDepartments = @("HR", "Consultants", "Finance", "IT", "Sales")

# Get all users with a Department attribute
$Users = Get-ADUser -Filter { Department -like "*" } -Properties Department

foreach ($User in $Users) {

    $Dept = $User.Department.Trim()

    # Skip if department is not in the allowed list
    if ($AllowedDepartments -notcontains $Dept) {
        Write-Host "Skipping $($User.SamAccountName): Department '$Dept' not in allowed list"
        continue
    }

    # Build the OU path for this department
    $DeptOU = "OU=$Dept,$BaseOU"

    # Create the OU if it doesn't exist
    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(ou=$Dept)" -SearchBase $BaseOU -ErrorAction SilentlyContinue)) {
        Write-Host "Creating OU: $DeptOU"
        New-ADOrganizationalUnit -Name $Dept -Path $BaseOU
    }

    # Move the user
    Write-Host "Moving $($User.SamAccountName) to $DeptOU"
    Move-ADObject -Identity $User.DistinguishedName -TargetPath $DeptOU
}