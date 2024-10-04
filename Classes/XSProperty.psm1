<#
 .SYNOPSIS
 Defines a single property definition within a class
#>
class XSProperty
{
    [string]$Name
    [string]$ClassName

    XSProperty([string]$Name)
    {
        $this.Name = $Name
    }
}
