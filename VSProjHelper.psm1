<#
 .SYNOPSIS
 Functions for getting the content of a xsproj file
#>

<#
 .SYNOPSIS
 Gets the source files from a project file
#>
function Get-SourceFilesFromProject {
    param (
        [string]$ProjectFilePath
    )

    $xml = [xml](Get-Content -Path $ProjectFilePath)

    $sourceFiles = $xml.Project.ItemGroup |
        Where-Object { $_.Compile } |
        ForEach-Object { $_.Compile } |
        Select-Object -ExpandProperty Include
    # not necessary but makes the function more readable
    return $sourceFiles
}

<#
.SYNOPSIS
Gets the number of source files from a project file
#>
function Get-SourceFileCount 
{
    param (
        [string]$XSprojectPath
    )

    $sourceFiles = Get-SourceFilesFromProject -ProjectFilePath $XSprojectPath
    return $sourceFiles.Count
}   
