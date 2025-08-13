<#
Vergleicht die .prg-Dateien aus der Projektdatei mit den tatsächlich vorhandenen im Projektverzeichnis und listet fehlende auf.
#>
function Compare-PrgFilesInProject {
    param (
        [string]$ProjectFilePath,
        [string]$ProjectRoot
    )
    $xml = [xml](Get-Content -Path $ProjectFilePath)
    $projectPrgFiles = $xml.Project.ItemGroup |
        Where-Object { $_.Compile } |
        ForEach-Object { $_.Compile } |
        Select-Object -ExpandProperty Include |
        Where-Object { $_ -like '*.prg' }
    $actualPrgFiles = Get-ChildItem -Path $ProjectRoot -Recurse -Filter *.prg | ForEach-Object { $_.FullName }
    $missing = @()
    foreach ($prg in $actualPrgFiles) {
        $relative = $prg.Replace($ProjectRoot + '\', '')
        if ($projectPrgFiles -notcontains $relative) {
            $missing += $relative
        }
    }
    Write-Host "Fehlende .prg-Dateien im Projektfile:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    return $missing
}
