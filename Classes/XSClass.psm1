<#
 .SYNOPSIS
 Defines the content of a single class definition
#>
using module .\XSMethod.psm1
using module .\XSProperty.psm1
using module .\XSConstructor.psm1

using namespace System.Collections.Generic

class XSClass
{
    [List[XSMethod]]$Methods
    [List[XSProperty]]$Properties
    [List[XSConstructor]]$Constructors
    [int]$PrivateVarsCount
    [string]$Name
    [Int]$LOC
    [bool]$HasComment

    XSClass([string]$Name)
    {
        $this.Name = $Name
    }

}