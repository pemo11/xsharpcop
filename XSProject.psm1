<#
 .SYNOPSIS
 Defines an XSProject with source files and references
#>

using namespace System.Collections.Generic
using namespace System.Windows.Forms

# import modules with class definitions
using module .\LogHelper.psm1
using module .\XSPrgFile.psm1
using module .\VSProjHelper.psm1
using module .\Classes\SourceFileContent.psm1
using module .\Classes\AnalysisResult.psm1
using module .\Classes\AnalysisDetail.psm1

Set-StrictMode -Version Latest

# Has no effects?
# Add-Type -AssemblyName System.Windows.Forms
# a XSProject.xsd1 manifest file does not help either  
# suggested by ChatPGT - no effect either and doesn't make sense too
# if (-not [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")) {
#    Add-Type -AssemblyName System.Windows.Forms
# }

class XSProject
{
    [String]$Name
    [String]$XSProjPath

    XSProject([string]$Name, [string]$XSProjPath)
    {
        $this.Name = $Name
        $this.XSProjPath = $XSProjPath
        $logName = "{0}_{1:dd}_{1:MM}_{1:yy}_analyze.log" -f $Name, (Get-Date)
        $logPath = Join-Path -Path $PSScriptRoot -ChildPath $logName
        $global:logger = [LogHelper]::new($logPath)
        $logMsg = "Starting analysis of project $($this.Name) in $($this.XSProjPath)"
        $global:logger.LogInfo($logMsg)
    }

    # Simple analyze without logging and UI
    [List[AnalysisResult]]SimpelAnalyze()
    {
        $sourceFiles = Get-SourceFilesFromProject -ProjectFilePath $this.XSProjPath
        $sourceFilesContent = [List[SourceFileContent]]::new()
        foreach($sourceFile in $sourceFiles)
        {
            $sourceFilePath = Join-Path -Path (Split-Path -Path $this.XSProjPath) -ChildPath $sourceFile
            $prgFile = [XSPrgFile]::new($sourceFilePath)
            $result = $prgFile.Analyze()
            $sourceFilesContent.Add($result)
        }
        $analysisResults = [List[AnalysisResult]]::new()
        foreach($content in $sourceFilesContent)
        {
            $analysisResult = [AnalysisResult]::new($content)
            # class definitions
            foreach($class in $content.classes) 
            {
                $detail = [AnalysisDetail]::new("Class", $class.Name)
                $detail.LOC = $class.LOC
                $detail.CC = $class.CC
                $detail.HasComment = $class.hasComment
                $detail.SourcefilePath = $content.Path
                $detail.Message = "Class with LOC: $($class.LOC), CC: $($class.CC) and HasComment: $($class.HasComment)"
                $analysisResult.Details.Add($detail)
            }
            # Process methods and constructors
            foreach($method in $content.Methods)
            {
                $detail = [AnalysisDetail]::new("Method", $method.Name)
                $detail.ClassName = $method.ClassName
                $detail.Signature = $method.Signature
                $detail.LOC = $method.LOC
                $detail.CC = $method.CC
                $detail.HasComment = $method.HasComment
                $detail.SourcefilePath = $content.Path
                $detail.Message = "Method with LOC $($method.LOC) and CC $($method.CC)"
                $analysisResult.Details.Add($detail)
            }
            foreach($constructor in $content.Constructors)
            {
                $detail = [AnalysisDetail]::new("Constructor", "")
                $detail.ClassName = $constructor.ClassName
                $detail.Signature = $constructor.Signature
                $detail.LOC = $constructor.LOC
                $detail.CC = $constructor.CC
                $detail.HasComment = $constructor.HasComment
                $detail.SourcefilePath = $content.Path
                $detail.Message = "Constructor with LOC $($constructor.LOC) and CC $($constructor.CC)"
                $analysisResult.Details.Add($detail)
            }
            $analysisResults.Add($analysisResult)
        }
        return $analysisResults
    }

    # [ListBox] as type does not work if the $LogListBox $null?
    # [System.Windows.Forms.ListBox]$LogListBox does not work either
    [List[AnalysisResult]]Analyze([ListBox]$LogListBox)
    {
        $logMsg = "Analyzing source files in $($this.XSProjPath)"
        $global:logger.LogInfo($logMsg)
        $LogListBox.Items.Add($logMsg)
        $LogListBox.SelectedIndex = $LogListBox.Items.Count - 1
        $sourceFiles = Get-SourceFilesFromProject -ProjectFilePath $this.XSProjPath
        $sourceFilesContent = [List[SourceFileContent]]::new()
        foreach($sourceFile in $sourceFiles)
        {
            $sourceFilePath = Join-Path -Path (Split-Path -Path $this.XSProjPath) -ChildPath $sourceFile
            $logMsg = "Analyzing $sourceFilePath"
            $global:logger.LogInfo($logMsg)
            $LogListBox.Items.Add($logMsg)
            $LogListBox.SelectedIndex = $LogListBox.Items.Count - 1
            $prgFile = [XSPrgFile]::new($sourceFilePath)
            $result = $prgFile.Analyze()
            $sourceFilesContent.Add($result)
            [Application]::DoEvents()
        }
        # Convert the sourceFiles into a list of AnalysisResult objects
        $analysisResults = [List[AnalysisResult]]::new()
        foreach($content in $sourceFilesContent)
        {
            $analysisResult = [AnalysisResult]::new($content)
            # class definitions
            foreach($class in $content.classes) 
            {
                $detail = [AnalysisDetail]::new("Class", $class.Name)
                $detail.ClassName = $class.Name
                $detail.LOC = $class.LOC
                $detail.SourcefilePath = $content.Path
                $detail.HasComment = $class.HasComment
                $detail.SourcefilePath = $content.Path
                $detail.Message = "Class $($class.name) LOC: $($class.LOC) HasComment: $($class.HasComment)"
                $analysisResult.Details.Add($detail)
            }
            # Process methods and constructors
            foreach($method in $content.Methods)
            {
                # $ElementType, $ElementName, $Message
                $detail = [AnalysisDetail]::new("Method", $method.Name)
                $detail.ClassName = $method.ClassName
                $detail.Signature = $method.Signature
                $detail.LOC = $method.LOC
                $detail.CC = $method.CC
                $detail.SourcefilePath = $content.Path
                $detail.Message = "Method with LOC $($method.LOC) and CC $($method.CC)"
                $analysisResult.Details.Add($detail)
            }
            foreach($constructor in $content.Constructors)
            {
                $detail = [AnalysisDetail]::new("Constructor", "")
                $detail.ClassName = $constructor.ClassName
                $detail.Signature = $constructor.Signature
                $detail.LOC = $constructor.LOC
                $detail.CC = $constructor.CC
                $detail.HasComment = $constructor.HasComment
                $detail.SourcefilePath = $content.Path
                $detail.Message = "Constructor with LOC $($constructor.LOC) and CC $($constructor.CC)"
                $analysisResult.Details.Add($detail)
            }
            $analysisResults.Add($analysisResult)
        }
        $logMsg = "Analysis completed for $($analysisResults.Count) source files"
        $global:logger.LogInfo($logMsg)
        return $analysisResults
    }

}










