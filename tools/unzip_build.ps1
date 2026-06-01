param(
    [string]$ZipName,
    [string]$DestName
)
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

if( Test-Path ..\build\$DestName) {
    Remove-Item -Path ..\build\$DestName -Recurse -Force
}
Expand-Archive -Path ..\build\$ZipName -DestinationPath ..\build\$DestName
