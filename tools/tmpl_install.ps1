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
	if(-not $gitdir){
		$GIT_DIR = Join-Path $env:LOCALAPPDATA "rpgcobo\tools\git"
		$GIT_URL = "https://github.com/git-for-windows/git/releases/download/v2.50.1.windows.1/MinGit-2.50.1-64-bit.zip"
		if( -not (Test-Path "$GIT_DIR")) {
			$TMP_ZIP = Join-Path $env:TEMP "mingit_tmp.zip"
			$TMP_DIR = Join-Path $env:TEMP "mingit_tmp"
			Invoke-WebRequest $GIT_URL -OutFile $TMP_ZIP
		    Remove-Item -Path $TMP_DIR -Recurse -Force
			Expand-Archive -Path $TMP_ZIP -DestinationPath $TMP_DIR
			mkdir (Join-Path $env:LOCALAPPDATA "rpgcobo\tools")
			Move-Item -Path $TMP_DIR -Destination $GIT_DIR
		}
		$git = "$GIT_DIR\cmd\git.exe"
	}
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
	Copy-Item -Path $srcdir -Destination $dstdir -Recurse -Force
}
