# ==============================
# Failed Logons Report (EventID 4625)
# ==============================

$RootPath  = "C:\Logs"
$Computers = @("DC1", "SRV1", "CL1")   # legg til/fjern maskiner her
$HoursBack = 24                            # hvor langt tilbake i tid

if (-not (Test-Path $RootPath)) {
    New-Item -ItemType Directory -Path $RootPath | Out-Null
}

# ------------------------------
# ScriptBlock: hent failed logons
# ------------------------------
$ScriptBlock = {
    param($HoursBack)

    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4625
        StartTime = (Get-Date).AddHours(-$HoursBack)
    } -ErrorAction Stop

    foreach ($e in $events) {

        # ---- LogonType ----
        # ---- LogonType (robust parsing fra Message) ----
$msg = $e.Message

$logonTypeNum = if ($msg -match "Logon Type:\s+(\d+)") {
    [int]$matches[1]
} else {
    -1
}

$logonTypeText = switch ($logonTypeNum) {
    2  { "Interactive" }
    3  { "Network" }
    4  { "Batch" }
    5  { "Service" }
    7  { "Unlock" }
    8  { "NetworkCleartext" }
    9  { "NewCredentials" }
    10 { "RDP" }
    11 { "CachedInteractive" }
    default { "Unknown" }
}

$logonTypeFinal = if ($logonTypeNum -gt 0) {
    "$logonTypeNum ($logonTypeText)"
} else {
    "Unknown"
}


        # ---- FailureReason (fra Message) ----
        $msg = $e.Message -replace "`r`n", " "
        $failureReason = if ($msg -match "Failure Reason:\s+(.*?)(?:Status|$)") {
            $matches[1].Trim()
        } else {
            "Unknown"
        }

        [PSCustomObject]@{
            Server        = $env:COMPUTERNAME
            Time          = $e.TimeCreated
            Account       = $e.Properties[5].Value
            Domain        = $e.Properties[6].Value
            IPAddress     = $e.Properties[19].Value
            LogonType     = $logonTypeFinal
            FailureReason = $failureReason
        }
    }
}

# ------------------------------
# Hent data fra alle maskiner
# ------------------------------
$Results = foreach ($Computer in $Computers) {
    Invoke-Command -ComputerName $Computer `
        -ScriptBlock $ScriptBlock `
        -ArgumentList $HoursBack `
        -ErrorAction SilentlyContinue
}

# ------------------------------
# CSV
# ------------------------------
$CsvPath = "$RootPath\FailedLogons.csv"
$Results | Sort-Object Time -Descending |
    Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

# ------------------------------
# HTML
# ------------------------------
$HtmlPath = "$RootPath\FailedLogons.html"

$html = @"
<html>
<head>
<title>Failed Logons Report</title>
</head>
<body>
<h1>Failed Logons (EventID 4625) – last $HoursBack hours</h1>
<table border="1" cellpadding="5">
<tr>
<th>Server</th>
<th>Time</th>
<th>Account</th>
<th>Domain</th>
<th>IP Address</th>
<th>LogonType</th>
<th>FailureReason</th>
</tr>
"@

foreach ($r in $Results | Sort-Object Time -Descending) {

    # RDP i rødt
    $logonColor = if ($r.LogonType -like "10*") { "red" } else { "black" }

    $html += "<tr>
        <td>$($r.Server)</td>
        <td>$($r.Time)</td>
        <td>$($r.Account)</td>
        <td>$($r.Domain)</td>
        <td>$($r.IPAddress)</td>
        <td><font color='$logonColor'>$($r.LogonType)</font></td>
        <td>$($r.FailureReason)</td>
    </tr>"
}

$html += "</table></body></html>"

$html | Out-File -FilePath $HtmlPath -Encoding UTF8

Write-Host "CSV:  $CsvPath"
Write-Host "HTML: $HtmlPath"

# ==============================
# Publiser HTML til IIS på SRV1
# ==============================

$DestinationServer = "SRV1"
$IISPath = "C:\inetpub\wwwroot\FailedLogons.html"

$session = New-PSSession -ComputerName $DestinationServer

Copy-Item -Path $HtmlPath `
          -Destination $IISPath `
          -ToSession $session `
          -Force

Remove-PSSession $session

Write-Host "HTML-rapport publisert til IIS på $DestinationServer"