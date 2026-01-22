# https://github.com/torivarm/dcst1005/blob/main/Guides/02-04-CreateGroups.md 

$domainPath = "DC=infrait,DC=sec"
function Create-Group {
    param (
        [String]$Name,
        [String]$Path
    )

    try {
        if (Get-ADGroup -Filter "Name -eq '$Name'") {
            # EXISTS -> error
            Write-Host "The group $Name already exists in $Path" -ForegroundColor Yellow
        } else {
            # DOESNT EXIST -> create
            New-ADGroup -Name $Name -GroupScope Global -GroupCategory Security -Path "$Path,$domainPath"
            Write-Host "Group $Name created successfully in $Path" -ForegroundColor Green
        }

    } catch {
        Write-Host "Something wrong happened"
    }
    
    
}

$InfraIT_Path = "OU=InfraIT_Groups" 

Create-Group -Name "g_all_hr" -Path $InfraIT_Path 
Create-Group -Name "g_all_it" -Path $InfraIT_Path
Create-Group -Name "g_all_sales" -Path $InfraIT_Path
Create-Group -Name "g_all_consultants" -Path $InfraIT_Path
Create-Group -Name "g_all_finance" -Path $InfraIT_Path
