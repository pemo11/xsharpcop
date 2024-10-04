<#
 .SYNOPSIS
 Various functions for writing Xml reports
#>

using module .\LogHelper.psm1

using namespace System.Xml.Linq

function Set-XmlAnalysisReport
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $xml = [XDocument]::new()
    $xml.Add([XDeclaration]::new("1.0", "UTF-8", $null))
    $root = [XElement]::new("AnalysisReport")
    $xml.Add($root)
    $xml.Save($Path)
    $logMsg = "Created XML analysis report at $Path"
    $global:logger.LogInfo($logMsg)
    
}