# 

# 

# 
function All-Members-Remove-From-Group {
    param (
        [Parameter(Mandatory=$false)]
        [string] $logPath = "remove_users_log.txt"

    )


    try {
        $salesUsers = Get-ADUser -Filter "department -eq 'Sales'" 
        $itUsers = Get-ADUser -Filter "department -eq 'IT'" 
        $hrUsers = Get-ADUser -Filter "department -eq 'HR'" 
        $financeUsers = Get-ADUser -Filter "department -eq 'Finance'" 
        $consultantsUsers = Get-ADUser -Filter "department -eq 'Consultants'" 

        $allUsers = @{
            Sales = $salesUsers
            IT = $itUsers
            HR = $hrUsers
            Finance = $financeUsers
            Consultants = $consultantsUsers
        }
    } catch {
        Write-Host "Something went wrong!" -ForegroundColor Yellow
        Write-Host $_
        exit 1
    }
    
    $log = @()
    

    foreach ($userGroup in $allUsers.Keys) {
        #Write-Host "ALL USERS IN $userGroup" -ForegroundColor Green
        #Write-Host ""
        foreach ($user in $allUsers.$userGroup) {
            #Write-Host $user.SamAccountName
            # For each 
            # Get user identity name
            # add to group Usergroup!
            # first check if has a group, then continue
            Remove-ADGroupMember -Identity "g_all_$($userGroup.toLower())" -Members $user.SamAccountName -Confirm:$false
            Write-Host "SUCCESS: Removed member $($user.SamAccountName) from group g_all_$($userGroup.toLower())" -ForegroundColor Green
            $log += "SUCCESS: Removed member $($user.samAccountName) from group g_all_$($userGroup.toLower())" 

        }
        #Write-Host "--------------"
    }

    $log | Out-File -FilePath $logPath

}


function All-Members-To-Group {
    param (
        [Parameter(Mandatory=$false)]
        [string] $logPath = "all_members_to_group_log.txt"

    )

    $log = @()

    try {
        $salesUsers = Get-ADUser -Filter "department -eq 'Sales'" 
        $itUsers = Get-ADUser -Filter "department -eq 'IT'" 
        $hrUsers = Get-ADUser -Filter "department -eq 'HR'" 
        $financeUsers = Get-ADUser -Filter "department -eq 'Finance'" 
        $consultantsUsers = Get-ADUser -Filter "department -eq 'Consultants'" 

        $allUsers = @{
            Sales = $salesUsers
            IT = $itUsers
            HR = $hrUsers
            Finance = $financeUsers
            Consultants = $consultantsUsers
        }
    } catch {
        Write-Host "Something went wrong!" -ForegroundColor Yellow
        Write-Host $_
        $log += $_
        exit 1
    }
    
    

    foreach ($userGroup in $allUsers.Keys) {
        
        foreach ($user in $allUsers.$userGroup) { 
            try {
                Add-ADGroupMember -Identity "g_all_$($userGroup.toLower())" -Members $user.SamAccountName
                Write-Host "Added $($user.SamAccountName) to group g_all_$($userGroup.toLower())" -ForegroundColor Green
                $log +=  "SUCCESS: Added $($user.SamAccountName) to group g_all_$($userGroup.toLower())"
            } catch {
                Write-Host "Something wrong happened when adding user $($user.SamAccountName) to group g_all_$($userGroup.toLower())" -ForegroundColor
                $log += "ERROR: $_"
                continue
            }
            

        }
        
    }

    $log | Out-File -FilePath $logPath

}

All-Members-To-Group

