<#
 .SYNOPSIS
 Defines the details for a single rule vilolation
#>

class RuleViolationDetail
{
    [string]$RuleName
    [string]$ElementName
    [string]$ElementType
    [string]$Message
    [string]$SourcefilePath
    [string]$Sourcefile
    [string]$ClassName
    [int]$LOC
    [int]$CC
    [bool]$HasComment
 
    RuleViolationDetail([string]$RuleName, [string]$ElementName, [string]$ElementType, [String]$ClassName, [string]$Message)
    {
        $this.RuleName = $RuleName
        $this.ElementName = $ElementName
        $this.ElementType = $ElementType
        $this.ClassName = $ClassName
        $this.Message = $Message
    }
}