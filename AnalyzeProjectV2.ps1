<#
 .SYNOPSIS
 Analyzing the prg files of a xsproj file and applies a rule to filter the results
#>

#requires -Module powershell-yaml
using module .\HelperClasses.psm1

$ProjPath = "C:\Users\pemo24\source\repos\basis.eureka-fach\Kernanwendung\EUREKAFach.xsproj"

$project = [XSProject]::new("Eureka", $ProjPath)

$rulePath = Join-Path -Path $PSScriptRoot -ChildPath "rules/ConstructorRule1.yaml"

$ruleObj = Get-Content -Path $rulePath | ConvertFrom-Yaml

$opDic = @{">" = "-gt"; "greaterThan" = "-gt"; "<" = "-lt"; "=" = "-eq"; "!=" = "-ne"; ">=" = "-ge"; "<=" = "-le"}

# $ruleConditionText = "`$_.Constructors.LOC -gt 100"
$ruleConditionText = "`$_.Constructors.$($ruleObj.Property) $($opDic[$ruleObj.Operator]) $($ruleObj.Value)"
$RuleCondition = [scriptblock]::Create($ruleConditionText)
$project.Analyze() | Where-Object $RuleCondition