<#
 .SYNOPSIS
 Analyzes the content of a single source file
#>

using namespace System.Collections.Generic

using module .\Classes\SourceFileContent.psm1
using module .\Classes\XSClass.psm1
using module .\Classes\XSMethod.psm1
using module .\Classes\XSProperty.psm1
using module .\Classes\XSConstructor.psm1
using module .\Helpers\AnalyzerHelpers.psm1

class XSPrgFile
{
    [String]$PrgfilePath

    XSPrgFile([string]$PrgPath)
    {
        $this.PrgfilePath = $PrgPath

    }

    [SourceFileContent]Analyze()
    {
        $logMsg = "Analyzing $($this.PrgfilePath)"
        $global:logger.LogInfo($logMsg)
        $codeLines = Get-Content -Path $this.PrgfilePath -Encoding UTF8
        $emptyLines = 0
        $commentLines = 0
        $classes = [List[XSClass]]::new()
        $methods = [List[XSMethod]]::new()
        $properties = [List[XSProperty]]::new()
        $constructors = [List[XSConstructor]]::new()
        $curItem = $null
        $class = $null
        $totalLOC = 0
        $curItemLOC = 0
        $codeBody = ""
        $className = ""
        $commentMode = $False
        for($i = 0; $i -lt $codeLines.Length; $i++) {
            $codeLine = $codeLines[$i]
            if ([String]::IsNullOrEmpty($codeLine.Trim()))
            {
                $emptyLines++
                continue
            }
            # order is important - must be before the // check
            if ($codeLine -match "/// <summary>")
            {
                $commentMode = $True
                continue
            }
            if ($codeLine.trim().StartsWith("//"))
            {
                $commentLines++
                continue
            }
            if ($codeLine -match '^\s*$')
            {
                $emptyLines++
                continue
            }
            # if ($codeLine -match '^\s*class\s+(\w+)\s*')
            # suggested by ChatGTP because of internal, sealed and partial classes
            $classRegex = '(?:Internal\s+|Partial\s+|Sealed\s+)*class\s+([a-zA-Z_][a-zA-Z0-9_]*)'
            if ($codeLine -match $classRegex)
            {
                $className = $matches[1]
                $class = [XSClass]::new($className)
                $class.hasComment = $commentMode
                $commentMode = $False
                $classes.Add($class)
                $curItem = $class
                continue
            }
            if ($codeline -match "End\s+Class")
            {
                $class.LOC = $totalLOC
                $totalLOC = 0
            }
            # if ($codeLine -match '^\s*method\s+(\w+)\s*')
            # ChatGTP said this [a-zA-Z_][a-zA-Z0-9_] is necessary to avoid a method name with a digit at the beginning (?)
            $methodRegex = "method\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*As\s+([a-zA-Z_][a-zA-Z0-9_]*)"
            if ($codeLine -match $methodRegex)
            {
                # update LOC for the current item
                # does not work $curItem?.LOC++ ?
                if ($null -ne $curItem -and $curItem -isnot [XSClass] -and $curItem -isnot [XSProperty])
                {
                    try {
                        $curItem.LOC = $curItemLOC
                        $curItem.CC = -1
                        $curItem = $null
                    }
                    catch {
                        Write-Host "XSPrgFile->Analyze: General error $($_.Exception.Message)"
                    }
                }
                $methodName = $matches[1]
                $method = [XSMethod]::new($methodName)
                $method.className = $className
                $method.signature = $matches[2]
                $method.hasComment = $commentMode
                $commentMode = $False
                $curItemLOC = 0
                $methods.Add($method)
                $curItem = $method
                continue
            }
            $propertyRegex = '^\s*property\s+(\w+)\s*'
            if ($codeLine -match $propertyRegex)
            {
                $propertyName = $matches[1]
                $property = [XSProperty]::new($propertyName)
                $property.ClassName = $className
                $properties.Add($property)
                $curItem = $property
                continue
            }
            # $constructorRegex = 'constructor\s*\(\s*([A-Za-z_]\w*\s+As\s+[A-Za-z_]\w*\s*,\s*)*([A-Za-z_]\w*\s+As\s+[A-Za-z_]\w*)\s*\)'
            $constructorRegex = "constructor\s*\((.*)\)"
            if ($codeLine -match $constructorRegex)
            {
                $constructorSignature = $matches[1..($Matches.Count-1)] -join ""
                $constructor = [XSConstructor]::new($constructorSignature)
                $constructor.className = $className
                $constructor.parameters = $matches[1..($Matches.Count-1)]
                $constructor.hasComment = $commentMode
                $commentMode = $False
                $curItemLOC = 0
                $constructors.Add($constructor)
                $curItem = $constructor
                continue
            }
            if ($codeLine -match '\bReturn\b')
            {
                if ($null -ne $curItem -and $curItem -isnot [XSClass] -and $curItem -isnot [XSProperty])
                {
                    try {
                        $curItem.LOC = $curItemLOC
                        $curItemLOC = 0
                        # calculate CC for the current item
                        $cc = Get-CiclomaticComplexity -Code $codeBody
                        # update CC for the return statement
                        $curItem.CC = $cc + 1
                        $codeBody = ""
                        $curItem = $null
                    }
                    catch {
                        Write-Host "XSPrgFile->Analyze: General error $($_.Exception.Message)"
                    }
                }
            }
            $codeBody += $codeLine
            $curItemLOC++
            $totalLOC++
        }
        $sourceFile = [SourceFileContent]::new($this.PrgfilePath)
        $sourceFile.Classes = $classes
        $sourceFile.Methods = $methods
        $sourceFile.Properties = $properties
        $sourceFile.Constructors = $constructors
        $sourceFile.TotalLOC = $TotalLOC
        $sourceFile.CommentLines = $commentLines
        $sourceFile.EmptyLines = $emptyLines
        # No real use yet
        $sourceFile.Status = "OK"
        return $sourceFile
    }
}