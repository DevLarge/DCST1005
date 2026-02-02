#CPU
#Memory
#Disk
#Network

$logPath = "C:\Logs\ServerMonitoring"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}

$servicesToCheck = @{
    "DC1"  = @("NTDS", "DNS", "Kdc", "DFSR", "Netlogon")
    "SRV1" = @("DFS", "W3SVC")
}

$interval = 2  # sekunder

while ($true) {

    $results = foreach ($server in @("DC1","SRV1")) {

        Invoke-Command -ComputerName $server -ScriptBlock {
            param($serverName)

            # Define the same mapping on the remote side
            $servicesToCheck = @{
                "DC1"  = @("NTDS", "DNS", "Kdc", "DFSR", "Netlogon")
                "SRV1" = @("DFS", "W3SVC")
            }

            $serviceList = $servicesToCheck[$serverName]

            $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples
            $memPercent = (Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples
            $diskRead = (Get-Counter '\PhysicalDisk(_Total)\Disk Read Bytes/sec').CounterSamples
            $diskWrite = (Get-Counter '\PhysicalDisk(_Total)\Disk Write Bytes/sec').CounterSamples
            $network = (Get-Counter '\Network Interface(*)\Bytes Total/sec').CounterSamples

            # Hent service-status
            $serviceStatus = foreach ($svc in $serviceList) {
                $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
                [PSCustomObject]@{
                    Name   = $svc
                    Status = if ($s) { $s.Status.ToString() } else { "NotFound" }
                }
            }

            [PSCustomObject]@{
                ComputerName   = $env:COMPUTERNAME
                Timestamp      = Get-Date
                CPU_Percent    = [math]::Round($cpu.CookedValue, 2)
                Memory_Percent = [math]::Round($memPercent.CookedValue, 2)
                Disk_Read      = [math]::Round(($diskRead.CookedValue | Measure-Object -Sum).Sum, 2)
                Disk_Write     = [math]::Round(($diskWrite.CookedValue | Measure-Object -Sum).Sum, 2)
                Network        = [math]::Round(($network.CookedValue | Measure-Object -Sum).Sum, 2)
                ServiceStatus  = ($serviceStatus | ConvertTo-Json -Compress)
            }
        } -ArgumentList $server
    }

    # Append til CSV — ONLY the correct fields
    $logFile = "$logPath\ServerStatus.csv"
    $results |
        Select-Object ComputerName, Timestamp, CPU_Percent, Memory_Percent, Disk_Read, Disk_Write, Network, ServiceStatus |
        Export-Csv -Path $logFile -NoTypeInformation -Append

    # Sjekk for kritiske verdier
    $critical = $results | Where-Object { $_.CPU_Percent -gt 90 -or $_.Memory_Percent -gt 90 }
    if ($critical) {
        $critical | ForEach-Object {
            $alert = "[ALERT] $($_.ComputerName) - CPU: $($_.CPU_Percent)% | Memory: $($_.Memory_Percent)%"
            Write-Host $alert -ForegroundColor Red
            Add-Content -Path "$logPath\Alerts_$(Get-Date -Format 'yyyyMMdd').txt" -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $alert"
        }
    }

    Start-Sleep -Seconds $interval
}