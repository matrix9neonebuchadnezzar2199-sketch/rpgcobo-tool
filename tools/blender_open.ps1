Using Module  .\gettool.psm1

param(
    [string]$Arg1
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "---------"
Write-Output "SK-OUTPUT popen_start"

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$TOOL_DIR = Join-Path $env:LOCALAPPDATA "rpgcobo\tools\blender"
$TOOL_URL = "https://mirror.freedif.org/blender/release/Blender4.5/blender-4.5.3-windows-x64.zip"
$INNER_DIR = "\blender-4.5.3-windows-x64"

GetTool -TOOL_DIR $TOOL_DIR -TOOL_URL $TOOL_URL -INNER_DIR $INNER_DIR

Write-Output "SK-OUTPUT popen_blender_addon"

Compress-Archive -Path "..\work\blender_rpgcobo" -DestinationPath ".\blender_rpgcobo.zip" -Force
&"$TOOL_DIR\blender.exe" -b --python-expr "import bpy; bpy.ops.preferences.addon_install(overwrite=True, filepath='.\\blender_rpgcobo.zip'); bpy.ops.preferences.addon_enable(module='blender_rpgcobo'); bpy.ops.wm.save_userpref()"
Remove-Item ".\blender_rpgcobo.zip"

Write-Output "SK-OUTPUT popen_launch"

$proc = Start-Process -FilePath "$TOOL_DIR\blender.exe" -ArgumentList $Arg1 -PassThru
while ($proc.MainWindowHandle -eq 0) {
    Start-Sleep -Milliseconds 200
    $proc.Refresh()
}

Write-Output "SK-OUTPUT popen_done"
