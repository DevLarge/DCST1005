# https://github.com/torivarm/dcst1005/blob/main/Guides/02-03-CreateOU.md 

$domainPath = "DC=infraIT,DC=sec"
function Create-ADOU {
    param (
        [string]$Name,
        [string]$Path
    )

    try {
        # Check if exists
        if (Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path) {
            # If exists
            Write-Host "OU: $Name already exists!" -ForegroundColor Yellow
            
        } else {
            # If not exists
            New-ADOrganizationalUnit -Name $Name -Path $Path
            Write-Host "OU: $Name in $Path was successfully created" -ForegroundColor Green
            
        }
    } catch {
        Write-Host "Error while creating ADOU" -ForegroundColor Red
        Write-Host $_ -ForegroundColor Red
        return $false
    }
} 

Create-ADOU -Name "InfraIT_Users" -Path $domainPath

Create-ADOU -Name "Finance" -Path "OU=InfraIT_Users,$domainPath"
Create-ADOU -Name "Sales" -Path "OU=InfraIT_Users,$domainPath"
Create-ADOU -Name "IT" -Path "OU=InfraIT_Users,$domainPath"
Create-ADOU -Name "Consultans" -Path "OU=InfraIT_Users,$domainPath"
Create-ADOU -Name "HR" -Path "OU=InfraIT_Users,$domainPath"


Create-ADOU -Name "InfraIT_Computers" -Path $domainPath

Create-ADOU -Name "Workstations" -Path "OU=InfraIT_Computers,$domainPath"
Create-ADOU -Name "Servers" -Path "OU=InfraIT_Computers,$domainPath"

Create-ADOU -Name "Finance" -Path "OU=Workstations,OU=InfraIT_Computers,$domainPath"
Create-ADOU -Name "Sales" -Path "OU=Workstations,OU=InfraIT_Computers,$domainPath"
Create-ADOU -Name "IT" -Path "OU=Workstations,OU=InfraIT_Computers,$domainPath"
Create-ADOU -Name "Consultants" -Path "OU=Workstations,OU=InfraIT_Computers,$domainPath"
Create-ADOU -Name "HR" -Path "OU=Workstations,OU=InfraIT_Computers,$domainPath"


Create-ADOU -Name "InfraIT_Groups" -Path $domainPath