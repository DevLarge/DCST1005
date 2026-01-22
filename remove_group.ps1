function Remove-Group {
    param (
        [string] $Name,
        [string] $Path
    )

    if (Get-ADGroup -Identity "$Name,$Path,$domainPath") {
        # Exists
        Remove-ADGroup -Identity "$Name,$Path,$domainPath" -Confirm:$false
        Write-Host "Group $Name was successfully removed" -ForegroundColor Green
    } else {
        # doesnt exist
        Write-Host "There is no group of name $Name" -ForegroundColor Red
    }
    
}