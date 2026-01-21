$domainPath = "DC=infraIT,DC=sec"
function Remove-ADOU {
    param (
        [string]$Name,
        [string]$Path
    )

    try {
        # Check if exists
        if (Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path) {
            # If exists
            if (Get-ADOrganizationalUnit -Identity "OU=$Name,$Path" -ErrorAction SilentlyContinue) {
                Set-ADOrganizationalUnit -Identity "OU=$Name,$Path" -ProtectedFromAccidentalDeletion $false
            }
            Remove-ADOrganizationalUnit -Identity "OU=$Name,$Path" -Confirm:$false
            Write-Host "OU: $Name in $Path was successfully deleted" -ForegroundColor Green
            return $true
        } else {
            # If not exists
            Write-Host "OU: $Name doesnt exist!" -ForegroundColor Yellow
            return $true
        }
    } catch {
        Write-Host "Error while deleting ADOU" -ForegroundColor Red
        Write-Host $_ -ForegroundColor Red
        return $false
    }
} 

$removed = Remove-ADOU -Name "TestOU\," -Path $domainPath