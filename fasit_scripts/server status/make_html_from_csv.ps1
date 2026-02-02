$csvPath = "C:\Logs\ServerMonitoring\ServerStatus.csv"

while ($true) {

    # CSS link
    $cssLink = '<link rel="stylesheet" type="text/css" href="monitor.css">'

    # Get latest entry per server
    $data = Import-Csv $csvPath |
        Group-Object ComputerName |
        ForEach-Object {
            $_.Group | Sort-Object Timestamp -Descending | Select-Object -First 1
        }

    # Convert JSON → colored HTML spans for the metrics table
    $data = $data | ForEach-Object {

        if ([string]::IsNullOrWhiteSpace($_.ServiceStatus)) {
            $html = "<span class='service-notfound'>No data</span>"
        }
        else {
            $services = ConvertFrom-Json $_.ServiceStatus

            $html = ($services | ForEach-Object {
                $class = switch ($_.Status) {
                    "Running"   { "service-running" }
                    "Stopped"   { "service-stopped" }
                    "NotFound"  { "service-notfound" }
                    default     { "service-notfound" }
                }
                "<span class='$class'>$($_.Name): $($_.Status)</span>"
            }) -join "<br>"
        }

        # Add new property for the metrics table
        $_ | Add-Member -NotePropertyName ServiceStatusHtml -NotePropertyValue $html -Force

        $_
    }

    # Build metrics table HTML
    $metricsHtml = $data |
        Select-Object ComputerName, Timestamp, CPU_Percent, Memory_Percent, Disk_Read, Disk_Write, Network |
        ConvertTo-Html -Fragment

    # Build services container (all services for each machine)
    # Build services container (all services for each machine)
$servicesHtml = "<div class='service-container'><h2>Services</h2>"

foreach ($entry in $data) {

    $servicesHtml += "<h3>$($entry.ComputerName)</h3>"

    # Parse JSON for this server
    $services = ConvertFrom-Json $entry.ServiceStatus

    foreach ($svc in $services) {

        $class = switch ($svc.Status) {
            "Running"   { "service-running" }
            "Stopped"   { "service-stopped" }
            "NotFound"  { "service-notfound" }
            default     { "service-notfound" }
        }

        # Add each service as its own line
        $servicesHtml += "<div class='service-line'><span class='$class'>$($svc.Name): $($svc.Status)</span></div>"
    }
}

$servicesHtml += "</div>"

    # Combine everything into one HTML page
    $htmlPage = @"
<html>
<head>
$cssLink
<title>Server Status</title>
</head>
<body>
<h1>Latest Metrics</h1>
$metricsHtml
<br><br>
$servicesHtml
</body>
</html>
"@

    # Push to SRV1
    Invoke-Command -ComputerName SRV1 -ScriptBlock {
        param($htmlContent)
        $htmlContent | Out-File "C:\inetpub\wwwroot\serverstatus.html" -Encoding UTF8
    } -ArgumentList $htmlPage

    Start-Sleep 60
}