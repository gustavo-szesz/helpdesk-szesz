$basePath = $PSScriptRoot

Get-ChildItem -Path $basePath -Recurse -Filter '*.ps1' |
ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function Test-*
Export-ModuleMember -Function Get-*
Export-ModuleMember -Function Set-*
Export-ModuleMember -Function Export-*