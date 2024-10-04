<#
 .SYNOPSIS
 A few tests for detecting comments in source files
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

Describe "Comment detection" {

    Context "Detecting comments in source files" {

        It "Creates a XSPrgFile object" {
            [XSPrgFile]::new($prgPath) | Should -BeOfType XSPrgFile
        }

        It "Checks constructor definition count" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext2.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            $content = $prgFile.Analyze()
            $content.Constructors.Count | Should -Be 2
        }

        It "Checks class comment count" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext2.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            $content = $prgFile.Analyze()
            @($content.Classes.Where{$_.HasComment}).Count | Should -Be 1
        }

        It "Checks constructor comment count" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext2.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            $content = $prgFile.Analyze()
            @($content.Constructors.Where{$_.HasComment}).Count | Should -Be 1
        }

        It "Checks methods comment count" {
            $prgPath = Join-Path -Path $PSScriptRoot -ChildPath "Quelltext2.prg"
            $prgFile = [XSPrgFile]::new($prgPath)
            $content = $prgFile.Analyze()
            @($content.Methods.Where{$_.HasComment}).Count | Should -Be 2
        }

    }
}