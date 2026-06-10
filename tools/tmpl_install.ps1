[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

$repourl = "https://github.com/djkotori/rpgcobo-assets.git,main";
$envpath = Join-Path (Get-Location) ".rpgcobo-env.local"
if( Test-Path "$envpath"){
	$env = (Get-Content $envpath -Encoding UTF8 | ConvertFrom-Json)
	$repourl = $env.repo_asset
}
Write-Output "Asset-Repository = $repourl"

# get/download template dir
$assetdir = ""
if( $repourl.StartsWith( "https://")){
	$git = (&where.exe "git.exe")
	$assetdir = Join-Path $env:TEMP "rpgcobo-assettmp"
	if( Test-Path "$assetdir"){
		Remove-Item -Path $assetdir -Recurse -Force
	}
	$a = $repourl.Split(",")
	&$git lfs install
	&$git clone -b $a[1] $a[0] $assetdir
} else {
	$assetdir = $repourl;
}

# get template info
$tmplpath = Join-Path $assetdir "rpgcobo_templates.json"
$tmpls = (Get-Content $tmplpath -Encoding UTF8 | ConvertFrom-Json)
$tmpl = $tmpls[0]

# copy files [{ src, dst },...]
foreach( $dirmap in $tmpl.dirs) {
	$srcdir = Join-Path $assetdir $dirmap.src
	$dstdir = Join-Path (Get-Location) $dirmap.dst
	if (-Not (Test-Path $dstdir)) {
		New-Item -Path $dstdir -ItemType Directory
	}
	Copy-Item -Path $srcdir\* -Destination $dstdir -Recurse -Force
}
