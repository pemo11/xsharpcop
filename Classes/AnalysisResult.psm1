<#
 .SYNOPSIS
 Defines a result element for the report
#>
using namespace System.Collections.Generic

using module ./SourceFileContent.psm1
using module ./AnalysisDetail.psm1

enum Severity
{
    Low
    Normal
    High
}

class AnalysisResult
{
    [string]$Path
    [string]$Filename
    [string]$AnalysisDate
    [Severity]$Severity
    [int]$ClassCount
    [int]$MethodsCount
    [int]$PropertiesCount
    [int]$EmptyLines
    [int]$TotalLOC
    [List[AnalysisDetail]]$Details

    AnalysisResult([SourceFileContent]$Content)
    {
        $this.Path = $Content.Path
        $this.Filename = Split-Path -Path $Content.Path -Leaf
        $this.AnalysisDate = Get-Date -Format d
        $this.ClassCount = $Content.Classes.Count
        $this.MethodsCount = $Content.Methods.Count
        $this.PropertiesCount = $Content.Properties.Count
        $this.EmptyLines = $Content.EmptyLines
        $this.TotalLOC = $Content.TotalLOC
        $this.Severity = [Severity]::Normal
        # Details for each method and constructor like LOC and CC
        $this.Details = [List[AnalysisDetail]]::new()   
    }
}
