<#
    .SYNOPSIS
    This module provides functions to log messages to a file  
#>

class LogHelper
{
    [String]$LogPath
    [String]$LogFileName
    [String]$LogFilePath

    LogHelper([String]$LogPath)
    {
        $this.LogFilePath = $LogPath
    }

    [void]LogInfo([String]$Message)
    {
        $Message = "*** [{0:T}] $Message" -f (Get-Date)
        $Message | Out-File -FilePath $this.LogFilePath -Append
    }

    [void]LogError([String]$Message)
    {
        $Message = "!!! [{0:T}] $Message" -f (Get-Date)
        $Message | Out-File -FilePath $this.LogFilePath -Append
    }

    [void]LogWarning([String]$Message)
    {
        $Message = "### [{0:T}] $Message" -f (Get-Date)
        $Message | Out-File -FilePath $this.LogFilePath -Append
    }
 
}