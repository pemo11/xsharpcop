<#
 .SYNOPSIS
 A few tests for the LOC counter
#>

#requires -module Pester

using module "../XSPrgFile.psm1"
using module "../LogHelper.psm1"
using module "../Classes/SourceFileContent.psm1"

BeforeAll {
    $logName = "{0}_{1:dd}_{1:MM}_{1:yy}_analyze.log" -f $Name, (Get-Date)
    $logPath = Join-Path -Path $PSScriptRoot -ChildPath $logName
    $global:logger = [LogHelper]::new($logPath)
    $logMsg = "Starting analysis of project $($this.Name) in $($this.XSProjPath)"
    $global:logger.LogInfo($logMsg)
}

Describe "LOCCounter" {

    Context "Counting lines of code" {

        It "Creates a XSPrgFile object" {
            [XSPrgFile]::new($prgPath) | Should -BeOfType XSPrgFile
        }

        It "Creates a SourceFileContent object" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext1.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            # [SourceFileContent]Analyze()
            $content = $prgFile.Analyze()
            $content | Should -BeOfType SourceFileContent
        }

        It "Counts number of classes" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext1.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            $content = $prgFile.Analyze()
            $content.Classes.Count | Should -Be 1
        }

        It "Counts number of methods" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext1.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            $content = $prgFile.Analyze()
            $content.Methods.Count | Should -Be 3
        }

        It "Counts the LOC in the constructor" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext1.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            $content = $prgFile.Analyze()
            $content.Constructors[0].LOC | Should -Be 7
        }
    }
}