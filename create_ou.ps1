$domainPath = "DC=infrait, DC=sec"
function Create-ADOU {
    param (
        [string]$Name,
        [string]$Path
    )

    try {
        # Check if exists
        if (Get-ADOrganizationalUnit -Filter "Name -eq $Name" -SearchBase $Path) {
            # If exists
            Write-Host "OU: $Name already exists!" -ForegroundColor Yellow
            return $true
        } else {
            # If not exists
            New-ADOrganizationalUnit -Name $Name -Path $Path
            Write-Host "OU: $Name in $Path was successfully created" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "Error while creating ADOU" -ForegroundColor Red
        Write-Host $_ -ForegroundColor Red
        return $false
    }
} 

$parentCreated = Create-ADOU -Name "TestParent" -Path $domainPath
Write-Host $parentCreated !!!!!

if ($parentCreated) {
    $childCreated = Create-ADOU -Name "TestChild" -Path "TestParent"
} else {
    Write-Host "Parent not exists"
    return $false
}

if ($childCreated) {
    child_childCreated = Create-ADOU -Name "TestChildChild" -Path "TestChild"
} else {
    Write-Host "parent doesnt exists"
    return $false
}

