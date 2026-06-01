
function GetTool
{
	param(
		[string]$TOOL_DIR,
		[string]$TOOL_URL,
		[string]$INNER_DIR
	)

	$TMP_ZIP = Join-Path $env:TEMP "rpgcobo_temp.zip"
	$TMP_DIR = Join-Path $env:TEMP "rpgcobo_temp"

	if (-not (Test-Path "$TOOL_DIR")) {
		############################# DOWNLOAD ###################################
		Write-Output "SK-OUTPUTP popen_download $TOOL_URL"
		$req = [System.Net.HttpWebRequest]::Create( $TOOL_URL)
		$res = $req.GetResponse()
		$total = $res.ContentLength
		$stream = $res.GetResponseStream()
		$file = [System.IO.File]::Create($TMP_ZIP)

		$buffer = New-Object byte[] 65536
		$received = 0
		while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
			$file.Write($buffer, 0, $read)
			$received += $read
			$percent = [math]::Round(($received / $total) * 1000)
			Write-Output "SK-PROGRESS $percent"
		}
		Write-Output "SK-PROGRESS 1000"
		$file.Dispose()
		$stream.Dispose()
		$res.Dispose()

		############################# EXTRACT ###################################
		Write-Output "SK-OUTPUTP popen_extract"
		if (Test-Path $TMP_DIR) { Remove-Item $TMP_DIR -Recurse -Force }
		New-Item -ItemType Directory -Path (Split-Path $TOOL_DIR) -Force | Out-Null

	#    Expand-Archive -Path $TMP_ZIP -DestinationPath $TMP_DIR -Force
		Add-Type -AssemblyName System.IO.Compression.FileSystem
		$zip = [IO.Compression.ZipFile]::OpenRead($TMP_ZIP)
		$entries = $zip.Entries
		$total   = $entries.Count
		$count   = 0

		foreach ($entry in $entries) {
			$count++
			$percent = [math]::Round(($count / $total) * 1000)
			Write-Output "SK-PROGRESS $percent"

			if ([string]::IsNullOrEmpty($entry.Name)) { continue }
			$target = Join-Path $TMP_DIR $entry.FullName
			$dir = Split-Path $target
			if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
			[IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
		}
		Write-Output "SK-PROGRESS 1000"
		$zip.Dispose()

		$EXT_DIR = Join-Path $TMP_DIR $INNER_DIR
		Move-Item $EXT_DIR $TOOL_DIR
	}
}
