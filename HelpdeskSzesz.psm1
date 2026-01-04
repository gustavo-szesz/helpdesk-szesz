$basePath = $PSScriptRoot

Get-ChildItem -Path $basePath -Recurse -Filter '*.ps1' |
ForEach-Object {
    . $_.FullName
}