<#
 .SYNOPSIS
 Defines a single constructor definition within a class
#>
class XSConstructor
{
    [string]$Signature
    [Object]$Parameters
    [string]$ClassName
    [Int]$LOC
    [Int]$CC
    [bool]$HasComment

    XSConstructor([string]$Signature)
    {
        $this.Signature = $Signature
    }
}
