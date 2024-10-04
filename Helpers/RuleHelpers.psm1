<#
 .SYNOPSIS
 Helper functions for evaluating the rules
#>

#requires -Module powershell-yaml

using module ..\Classes\RuleViolationDetail.psm1
using module ..\LogHelper.psm1

using namespace System.Collections.Generic
using namespace System.Data

<#
 .SYNOPSIS
Test the rule text
#>
function Test-XSCopRule
{
    [CmdletBinding()]
    param([string]$RuleText)
    try {
        $Result = $RuleText | ConvertFrom-Yaml
        $null -ne $Result ? $true : $false
    }
    catch {
        $logMsg = "Error parsing rule: $_"
        $global:logger.LogError($logMsg)
        $false
    }
}

<#
title: Alle Konstruktoren mit mehr als 100 Zeilen Code
name: ConstructorRule
object: Constructor
property: LOC
operator: GreaterThan
value: 100
#>

<#
 .SYNOPSIS
Replace the operator with the corresponding PowerShell operator
#>
function Update-Operator
{
    [CmdletBinding()]
    param([string]$Operator)
    switch ($Operator)
    {
        "GreaterThan" {"-gt"}
        "LessThan" {"-lt"}
        "Equal" {"-eq"}
        "NotEqual" {"-ne"}
        "GreaterOrEqual" {"-ge"}
        "LessOrEqual" {"-le"}
        default {"-eq"}
    }
}

<#
.SYNOPSIS
Invoke a single rule on the codebase that consists of AnalsisDetail objects with ElementType, ElementName, Message, CC and LOC
#>
function Invoke-XSCopeRule
{
    [CmdletBinding()]
    param(
        [object]$Rule,
        [object[]]$Codebase
    )
    $operator = Update-Operator -Operator $Rule.operator
    $ruleName = $Rule.Name
    $ruleProp = $Rule.Property
    $elementType = $Rule.Object
    $value = $Rule.Value
    $logMsg = "Invoking rule $($Rule.Name)"
    $global:logger.LogInfo($logMsg)
    $sbText = "`$_.ElementType -eq '$elementType' -and `$_.$ruleProp $operator $value"
    $sbFilter = [ScriptBlock]::Create($sbText)
    # create list of RuleViolationDetail objects as return value
    $ruleResults = [List[RuleViolationDetail]]::new()
    # go through all AnalysisResult objects
    $Codebase.ForEach{
        $logMsg = "Applying rule $ruleName on $($_.Filename)"
        $global:logger.LogInfo($logMsg)
        # Get all rule violations for the current file
        # explicity type convertion to [ScriptBlock]?
        $violationsFound = $_.Details | Where-Object $sbFilter
        # Convert to rule results
        foreach($violation in $violationsFound)
        {
            $ruleResult = [RuleViolationDetail]::new($Rule.Name, $violation.ElementType, $vioation.ElementName, $violation.ClassName, $violation.Message)
            $ruleResult.SourcefilePath = $violation.SourcefilePath
            $ruleResult.Sourcefile = Split-Path -Path $violation.SourcefilePath -Leaf
            $ruleResult.LOC = $violation.LOC
            if ($ruleResult.PSObject.Properties.Name -contains "CC")    
            {
                $ruleResult.CC = $violation.CC
            }   
            $ruleResult.HasComment = $violation.HasComment
            $ruleResults.Add($ruleResult)
        }
    
    }
    # return the list of RuleViolationDetail objects as a whole
    ,$ruleResults
}

<#
 .SYNOPSIS
 Convert a list of RuleViolationDetail objects to a DataTable
#>
function ConvertRuleViolationsTo-DataTable
{
    [CmdletBinding()]
    param(
        [List[RuleViolationDetail]]$Details
    )
    $ta = [DataTable]::New()
    [Void]$ta.Columns.Add("RuleName", [String])
    [Void]$ta.Columns.Add("ElementType", [String])
    [Void]$ta.Columns.Add("ElementName", [String])
    [Void]$ta.Columns.Add("ClassName", [String])
    [Void]$ta.Columns.Add("Message", [String])
    [Void]$ta.Columns.Add("SourcefilePath", [String])
    [Void]$ta.Columns.Add("Sourcefile", [String])
    [Void]$ta.Columns.Add("LOC", [Int])
    [Void]$ta.Columns.Add("CC", [Int])
    # does not work because its not of type Array?
    # $Details.ForEach{
    $Details | ForEach-Object {
        $row = $ta.NewRow()
        $row["RuleName"] = $_.RuleName
        $row["ElementType"] = $_.ElementType
        $row["ElementName"] = $_.ElementName
        $row["ClassName"] = $_.ClassName
        $row["Message"] = $_.Message
        $row["SourcefilePath"] = $_.SourcefilePath
        $row["Sourcefile"] = $_.Sourcefile
        $row["LOC"] = $_.LOC
        $row["CC"] = $_.CC
        $ta.Rows.Add($row)
    }
    # Import: don't forget the comma
    return ,$ta
}

<#
 .SYNOPSIS
 Convert a list of AnalysisDetail objects to a DataTable
#>
function ConvertAnalysisResultsTo-DataTable
{
    [CmdletBinding()]
    param(
        [List[AnalysisDetail]]$Details
    )
    $ta = [DataTable]::New()
    [Void]$ta.Columns.Add("ClassName", [String])
    [Void]$ta.Columns.Add("Name", [String])
    [Void]$ta.Columns.Add("SourcefilePath", [String])
    [Void]$ta.Columns.Add("LOC", [Int])
    [Void]$ta.Columns.Add("HasComment", [Boolean])
    $Details | ForEach-Object {
        $row = $ta.NewRow()
        $row["ClassName"] = $_.ClassName
        $row["Name"] = $_.ElementName
        $row["SourcefilePath"] = $_.SourcefilePath
        $row["LOC"] = $_.LOC
        $row["HasComment"] = $_.HasComment
        $ta.Rows.Add($row)
    }
    # Import: don't forget the comma
    return ,$ta

   
}