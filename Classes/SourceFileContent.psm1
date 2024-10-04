<#
 .SYNOPSIS
Defines the content of a prg file with classes and/or functions
#>

using namespace System.Collections.Generic

using module .\XSClass.psm1
using module .\XSMethod.psm1
using module .\XSProperty.psm1
using module .\XSConstructor.psm1

class SourceFileContent
{
    [List[XSClass]]$Classes
    [List[XSMethod]]$Methods
    [List[XSProperty]]$Properties
    [List[XSConstructor]]$Constructors
    [string]$Path
    [int]$EmptyLines
    [int]$CommentLines
    [int]$TotalLOC
    [string]$Status

    SourceFileContent([String]$Path)
    {
        $this.Path = $Path
    }
    
}
