<#
Split large text/markdown files into smaller chunks to avoid token-limit issues when editing.
Usage examples:
  powershell -File .\docs\split-file.ps1 -File .\app_summary.md -LinesPerFile 500
  .\docs\split-file.ps1 -File .\app_summary.md -LinesPerFile 300
#>
param(
    [Parameter(Mandatory=$true)][string]$File,
    [int]$LinesPerFile = 500,
    [string]$OutDir = (Split-Path -Path $File),
    [string]$Prefix = (Split-Path -Leaf $File)
)

if (-not (Test-Path -Path $File)) {
    Write-Error "File not found: $File"
    exit 2
}

$counter = 1
$chunk = @()
$lineCount = 0

Get-Content -Path $File -Encoding UTF8 | ForEach-Object -Process {
    $chunk += $_
    $lineCount++
    if ($lineCount -ge $LinesPerFile) {
        $outName = "{0}.part{1:d4}{2}" -f $Prefix, $counter, ([IO.Path]::GetExtension($File))
        $outPath = Join-Path $OutDir $outName
        ($chunk -join "`n") | Out-File -FilePath $outPath -Encoding UTF8
        Write-Output "Wrote: $outPath"
        $counter++
        $chunk = @()
        $lineCount = 0
    }
} -End {
    if ($chunk.Count -gt 0) {
        $outName = "{0}.part{1:d4}{2}" -f $Prefix, $counter, ([IO.Path]::GetExtension($File))
        $outPath = Join-Path $OutDir $outName
        ($chunk -join "`n") | Out-File -FilePath $outPath -Encoding UTF8
        Write-Output "Wrote: $outPath"
    }
}
