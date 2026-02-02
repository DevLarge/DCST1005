$logPath = "C:\Logs\ServerMonitoring"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}

$servers = @("DC1", "SRV1", "CL1", "MGR")   # legg til flere hvis du vil

$logFile = "$logPath\LoginFailures.csv"

while ($true) {

    $results = foreach ($server in $servers) {

        Invoke-Command -ComputerName $server -ScriptBlock {

            # Hent siste 5 minutter med feillogger
            $events = Get-WinEvent -FilterHashtable @{
                LogName = 'Security'
                Id      = 4625
                StartTime = (Get-Date).AddMinutes(-5)
            }

            foreach ($event in $events) {

                $xml = [xml]$event.ToXml()

                # Hent ut relevante felter
                [PSCustomObject]@{
                    Timestamp   = $event.TimeCreated
                    Computer    = $env:COMPUTERNAME
                    Username    = $xml.Event.EventData.Data[5].'#text'
                    IPAddress   = $xml.Event.EventData.Data[19].'#text'
                    FailureCode = $xml.Event.EventData.Data[7].'#text'
                    Reason      = $xml.Event.EventData.Data[8].'#text'
                }
            }
        }
    }

    if ($results) {
        $results | Export-Csv -Path $logFile -NoTypeInformation -Append
    }

    Start-Sleep -Seconds 2
}