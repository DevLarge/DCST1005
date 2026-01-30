# Check GPO exists
Get-GPO -Name "Drive Mapping - Department Shares"

# View GPO report
Get-GPOReport -Name "Drive Mapping - Department Shares" -ReportType HTML -Path "C:\Temp\GPO-Report.html"