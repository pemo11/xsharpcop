<#
 .SYNOPSIS
 Searching contructors without comments
.NOTES
Muss wegen System.Windows.Forms über StartAnalyzer.ps1 gestartet werden
#>

using module .\XSProject.psm1

$ProjPath = "C:\Users\pemo24\source\repos\basis.eureka-fach\Kernanwendung"
$ProjPath = "D:\GitRepos\basis.eureka-fach\Kernanwendung\EUREKAFach.xsproj"

$project = [XSProject]::new("Eureka", $ProjPath)
$result = $project.SimpelAnalyze() 
$result | Select-Object -ExpandProperty Details |  Where-Object {$_.ElementType -eq "Constructor" -and $_.HasComment -eq $false}
