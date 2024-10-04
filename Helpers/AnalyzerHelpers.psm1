<#
 .SYNOPSIS
 Contains helper functions for analzying the source code
#>

<#
 .SYNOPSIS
 Calculates the Ciclomatic Complexity of a method provided as a string
#>
function Get-CiclomaticComplexity
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Code
    )
    $complexity = 1
    # pure genius;)
    $complexity += ($Code -split "\b(if|else|elseif|while|for|case|catch|throw|return|&&|\|\|)\b").Count - 1
    return $complexity
}

