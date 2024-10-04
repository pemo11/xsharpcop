<#
 .SYNOPSIS
 Defines the details of an analysis result
 #>
class AnalysisDetail
{
    [string]$ElementType
    [string]$ElementName
    [string]$ClassName
    [string]$Signature
    [string]$Message
    [string]$SourcefilePath
    [int]$LOC
    [int]$CC
    [bool]$HasComment

    # Constructor with type of element and its name
    AnalysisDetail([string]$ElementType, [string]$ElementName)
    {
        $this.ElementType = $ElementType
        $this.ElementName = $ElementName
    }

}


