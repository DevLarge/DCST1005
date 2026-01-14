try {
    $ou = Get-ADOrganizationalUnit -Filter "Name -eq 'TestOU'" -SearchBase "DC=infrait,DC=sec" -ErrorAction Stop | Select-Object -ExpandProperty DistinguishedName

    if ($ou) {
        Write-Host "OU ble funnet: $ou"
    } else {
        Write-Host "OU Finnes IKKE i domenet"
    }
} catch {
    Write-Host "Oppstod feil ved henting av variabel"
}