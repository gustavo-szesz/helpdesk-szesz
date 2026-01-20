function Get-SystemInfo {
    [CmdletBinding()]
    param ()

    $timestamp = Get-Date
    $bios = Get-CimInstance Win32_BIOS
    $computerSystem = Get-CimInstance Win32_ComputerSystem

    [PSCustomObject]@{
        Category        = 'SystemInfo'
        Timestamp       = $timestamp
        ComputerName    = $computerSystem.Name
        Domain          = $computerSystem.Domain
        CurrentUser     = "$env:USERDOMAIN\$env:USERNAME"
        Manufacturer    = $computerSystem.Manufacturer
        Model           = $computerSystem.Model 
        SerialNumber    = $bios.SerialNumber
        Result          = 'OK'
    }
}

function Get-SystemInfoJson {
    [CmdletBinding()]
    param ()
    $timestamp = (Get-Date).ToString('o')
    $item = Get-SystemInfo
    return [PSCustomObject]@{
        Category          = 'SystemInfo'
        ComputerName      = $env:COMPUTERNAME
        Timestamp         = $timestamp
        Status            = 'OK'
        Data              = $item
    }
    
}


