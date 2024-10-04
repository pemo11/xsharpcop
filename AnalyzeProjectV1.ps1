<#
 .SYNOPSIS
 Analyzing a directory with prg files
#>

using module .\HelperClasses.psm1

$ProjPath = "C:\Users\pemo24\source\repos\basis.eureka-fach\Kernanwendung"

$project = [XSProject]::new("Eureka", $ProjPath)
$project.Analyze() | Where-Object Constructors -ne $null  | Select-Object -ExpandProperty Constructors -Property Path |
 Where-Object LOC -gt 100 | Sort-Object LOC -Descending
