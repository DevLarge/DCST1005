Invoke-Command -ComputerName srv1 -ScriptBlock {
    $shares = @('Finance','Sales','IT','Consultants','HR','files')
    
    foreach ($share in $shares) {
        $shareInfo = Get-SmbShare -Name $share -ErrorAction SilentlyContinue
        if ($shareInfo) {
            Write-Host "`n=== $share ===" -ForegroundColor Cyan
            Write-Host "Path: $($shareInfo.Path)"
            Write-Host "Description: $($shareInfo.Description)"
            Write-Host "`nPermissions:"
            Get-SmbShareAccess -Name $share | Format-Table AccountName, AccessControlType, AccessRight -AutoSize
        }
    }
}