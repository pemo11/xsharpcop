<#
 .SYNOPSIS
 Defines a single method definition within a class
#>
class XSMethod
{
    [string]$Name
    [string]$Signature
    [string]$ClassName
    [int]$LocalVarsCount
    [Int]$LOC
    [Int]$CC
    [bool]$HasComment

    XSMethod([string]$Name)
    {
        $this.Name = $Name
    }
}