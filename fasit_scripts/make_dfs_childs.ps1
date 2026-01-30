Invoke-Command -ComputerName srv1 -ScriptBlock {
    Write-Host "`n=== C:\dfsroots ===" -ForegroundColor Cyan
    Get-ChildItem -Path C:\dfsroots -Directory -Recurse | ForEach-Object {
        Write-Host "  $($_.FullName)" -ForegroundColor Green
    }
    
    Write-Host "`n=== C:\shares ===" -ForegroundColor Cyan
    Get-ChildItem -Path C:\shares -Directory | ForEach-Object {
        Write-Host "  $($_.FullName)" -ForegroundColor Green
    }
}