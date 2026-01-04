<#
 # {#Pegar uso de memoria RAM 
GEt-Process | Select-Object ProcessName, @{ Name = "Memoria_GB"  Expression = { $_.PM / 1000000000 } }

#Pegar servicos e separar por status 
Get-Service | Group-Object Status |
>> ForEach-Object {
>> Write-Host ""
>> Write-Host "===$($_.Name)" -ForegroundColor Cyan
>> $_.Group | ForEach-Object {
>> "{0}, {1}" -f $_.DisplayName, $_.Name
>> }
>> }

Get-NetTCPConnection | Where-Object State -eq 'Established' | Group-Object OwningProcess | ForEach-Object { $pids = $_.Name
>> $process = Get-Process -Id $pids -ErrorAction SilentlyContinue
>> foreach ($conn in $_.Group) {
>> [pscustomobject]@{
>> ProcessName = $process.ProcessName
>> PID = $pids
>> LocalAddress = $conn.LocalAddress
>> RemoteAddress  = $conn.RemoteAddress
>>             RemotePort     = $conn.RemotePort
>>             State          = $conn.State
>>         }
>>     }
>> }


# Separar serviiços parados e rodando 
Get-Service | ForEach-Object {

    if ($_.Status -ne "Running") {

        [PSCustomObject]@{
            Category = "Service"
            Name     = $_.Name
            Status   = $_.Status
            Result   = "ALERT"
        }

    } else {

        [PSCustomObject]@{
            Category = "Service"
            Name     = $_.Name
            Status   = $_.Status
            Result   = "OK"
        }
    }
}


# Serviços criticos rodando 
Get-Service |
Where-Object { $_.Name -in $criticos } |
ForEach-Object {

    if ($_.Status -ne "Running") {

        [PSCustomObject]@{
            Category = "Service"
            Name     = $_.Name
            Status   = $_.Status
            Result   = "ALERT"
        }

    } else {

        [PSCustomObject]@{
            Category = "Service"
            Name     = $_.Name
            Status   = $_.Status
            Result   = "OK"
        }
    }
}

:Enter a comment or description}
#>