<#
 .SYNOPSIS
 A simple UI for using XSharpCop rules
#>

using namespace System.Windows.Forms
using namespace System.Drawing

# import modules with class definitions
using module .\LogHelper.psm1
using module .\VSProjHelper.psm1
using module .\XSProject.psm1
using module .\XSPrgFile.psm1

using module .\Classes\AnalysisResult.psm1
using module .\Classes\AnalysisDetail.psm1
using module .\Classes\SourceFileContent.psm1

Set-StrictMode -Version Latest 

# Still necessary 
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# import regular modules
$psm1Path = Join-Path -Path $PSScriptRoot -ChildPath "Helpers\RuleHelpers.psm1"
Import-Module -Name $psm1Path -Force

function InitButtons
{
    $btnChooseProject.Enabled = $true
    $btnLoadProject.Enabled = $true
    $btnLoadRuleFile.Enabled = $false
    $btnAnalyzeRules.Enabled = $false
    $btnAnalyzeCodebase.Enabled = $false
}

function InitializeComponents
{
    param([Form]$Form)
    $tabLayout = [TableLayoutPanel]::new()

    $tabLayout.Dock = [DockStyle]::Fill
    $tabLayout.ColumnCount = 1
    $tabLayout.RowCount = 4
    [Void]$tabLayout.RowStyles.Add([RowStyle]::new([SizeType]::Percent, 15))
    [Void]$tabLayout.RowStyles.Add([RowStyle]::new([SizeType]::Percent, 20))
    [Void]$tabLayout.RowStyles.Add([RowStyle]::new([SizeType]::Percent, 30))
    [Void]$tabLayout.RowStyles.Add([RowStyle]::new([SizeType]::Percent, 35))
    [Void]$tabLayout.ColumnStyles.Add([ColumnStyle]::new([SizeType]::Percent, 100))

    # Project Group
    $grpProject = [GroupBox]::new()
    $grpProject.Text = "Project"
    $grpProject.Dock = [DockStyle]::Fill

    $btnChooseProject = [Button]::new()
    $btnChooseProject.Size = [Size]::new(120, 30)
    $btnChooseProject.Location = [Point]::new(20, 20)
    $btnChooseProject.Text = "Choose project"

    $btnLoadProject = [Button]::new()
    $btnLoadProject.Size = [Size]::new(120, 30)
    $btnLoadProject.Location = [Point]::new(20, 60)
    $btnLoadProject.Text = "Load project"

    $Script:lblProjectPath = [Label]::new()
    $lblProjectPath.Size = [Size]::new(600, 30)
    $lblProjectPath.Text = "No project chosen"
    $lblProjectPath.TextAlign = [ContentAlignment]::MiddleLeft
    $lblProjectPath.AutoSize = $false
    $lblProjectPath.BackColor = [Color]::LightYellow
    $lblProjectPath.Location = [Point]::new(150, 20)

    $Script:lblSourceFileCount = [Label]::new()
    $lblSourceFileCount.Size = [Size]::new(100, 24)
    $lblSourceFileCount.Text = "0"
    $lblSourceFileCount.TextAlign = [ContentAlignment]::MiddleLeft
    $lblSourceFileCount.AutoSize = $false
    $lblSourceFileCount.BackColor = [Color]::LightGreen
    $lblSourceFileCount.Location = [Point]::new(150, 60)

    $Script:btnAnalyzeCodebase = [Button]::new()
    $btnAnalyzeCodebase.Size = [Size]::new(120, 30)
    $btnAnalyzeCodebase.Location = [Point]::new(630, 60)
    $btnAnalyzeCodebase.Text = "Analyze codebase"

    # Add all controls to the group control (usally with AddRange())
    $grpProject.Controls.Add($btnChooseProject)
    $grpProject.Controls.Add($btnLoadProject)
    $grpProject.Controls.Add($lblProjectPath)
    $grpProject.Controls.Add($lblSourceFileCount)
    $grpProject.Controls.Add($btnAnalyzeCodebase)

    # Rules Group
    $grpRules = [GroupBox]::new()
    $grpRules.Text = "Rules"
    $grpRules.Dock = [DockStyle]::Fill

    $Script:btnLoadRuleFile = [Button]::new()
    $btnLoadRuleFile.Size = [Size]::new(120, 30)
    $btnLoadRuleFile.Location = [Point]::new(20, 20)
    $btnLoadRuleFile.Text = "Load Rule file"

    $Script:btnAnalyzeRules = [Button]::new()
    $btnAnalyzeRules.Size = [Size]::new(120, 30)
    $btnAnalyzeRules.Location = [Point]::new(20, 60)
    $btnAnalyzeRules.Text = "Analyze Rules"

    $Script:btnUpdateRuleFile = [Button]::new()
    $btnUpdateRuleFile.Size = [Size]::new(120, 30)
    $btnUpdateRuleFile.Location = [Point]::new(760, 20)
    $btnUpdateRuleFile.Text = "Update rule file"

    $Script:lblXScpRulefilePath = [Label]::new()
    $lblXScpRulefilePath.Size = [Size]::new(598, 30)
    $lblXScpRulefilePath.Text = "No rule file chosen"
    $lblXScpRulefilePath.TextAlign = [ContentAlignment]::MiddleLeft
    $lblXScpRulefilePath.AutoSize = $false
    $lblXScpRulefilePath.BackColor = [Color]::LightYellow
    $lblXScpRulefilePath.Location = [Point]::new(150, 10)

    $Script:txtRuleContent = [TextBox]::new()
    $txtRuleContent.Size = [Size]::new(600, 100)
    $txtRuleContent.Location = [Point]::new(150, 40)
    $txtRuleContent.BackColor = [Color]::LightSalmon
    $txtRuleContent.Multiline = $true
    $txtRuleContent.ScrollBars = "Vertical"

    $btnChooseProject.Add_Click({
        $fileBrowser = [OpenFileDialog]::new()
        $fileBrowser.Title = "Choose the project file"
        $fileBrowser.Filter = "XSharp Project Files (*.xsproj)|*.xsproj|All Files (*.*)|*.*"
        $fileBrowser.InitialDirectory = $Script:config.ProjectBasePath
        if ($fileBrowser.ShowDialog()) {
            $Script:XSprojectPath = $fileBrowser.FileName
            # Scope Modifier necessary?
            $Script:lblProjectPath.Text = $Script:XSprojectPath
        } 
    })

    # using script: is optional except for the time when the object is created to set the scope
    $btnLoadProject.Add_Click({
        $Script:SourceFileCount = Get-SourceFileCount -XSprojectPath $Script:XSprojectPath
        $lblSourceFileCount.Text = "$($Script:SourceFileCount) source files"
        $btnLoadRuleFile.Enabled = $true
        $btnAnalyzeCodebase.Enabled = $true
    })

    $btnAnalyzeCodebase.Add_Click({
        $project = [XSProject]::new("Eureka", $XSprojectPath)
        $analysisResult = $project.Analyze($Script:lsbLog)
        $taResults = ConvertAnalysisResultsTo-DataTable -Details $analysisResult.Details
        $bindingSource = [BindingSource]::new()
        $bindingSource.DataSource = $taResults.DefaultView
        $Script:dgvResults.DataSource = $bindingSource
    })
    
    $btnLoadRuleFile.Add_Click({
        $fileBrowser = [OpenFileDialog]::new()
        $fileBrowser.Title = "Choose a rule file"
        $fileBrowser.Filter = "XSharpCop rule files (*.yaml)|*.yaml|All Files (*.*)|*.*"
        $fileBrowser.InitialDirectory = Join-Path -Path $PSScriptRoot -ChildPath Rules
        if ($fileBrowser.ShowDialog()) {
            $Script:XScpRulefilePath = $fileBrowser.FileName
            # Scope Modifier necessary?
            $Script:lblXScpRulefilePath.Text = $XScpRulefilePath
            $Script:txtRuleContent.Text = Get-Content -Path $XScpRulefilePath -Raw
            $btnAnalyzeRules.Enabled = $true
        } 
    })

    # update the rule file with the textbox content
    $btnUpdateRuleFile.Add_Click({
        Set-Content -Path $XScpRulefilePath -Value $txtRuleContent.Text
    })

    # starts the analysis
    $btnAnalyzeRules.Add_Click({
        # check for a valid rule
        $ruleText = $Script:txtRuleContent.Text
        if ($ruleText -eq "") {
            [MessageBox]::Show("No rule loaded", "Error", [MessageBoxButtons]::OK, [MessageBoxIcon]::Error)
            return
        }
        if (!(Test-XSCopRule -RuleText $ruleText)) {
            [MessageBox]::Show("The current rule is not a valid rule", "Error", [MessageBoxButtons]::OK, [MessageBoxIcon]::Error)
            return
        }
        $btnAnalyzeRules.Enabled = $false
        $Script:startTime = Get-Date
        $currentRule = $ruleText | ConvertFrom-Yaml
        $project = [XSProject]::new("Eureka", $XSprojectPath)
        # starts the analysis with a ListBox output
        $Script:lsbLog.Items.Clear()
        $analysisResult = $project.Analyze($Script:lsbLog)
         
        $Script:endTime = (Get-Date) - $Script:startTime
        $classCount =  ($analysisResult | Measure-Object -Property ClassCount -Sum).Sum
        $logMsg = "Analysis completed for $classCount classes in {0:f2} seconds" -f $endTime.TotalSeconds
        $Global:logger.LogInfo($logMsg)
        [MessageBox]::Show($logMsg, "Operation status")
        # Prepare the view
        # $view1 = @{n="File";e={Split-Path -Path $_.Path}}, "Severity", "ClassCount", "MethodsCount", "PropertiesCount", "EmptyLines", "TotalLOC", "CC"
        # $analysisResultView = $analysisResult | Select-Object -Property $view1 | Sort-Object -Property Severity -Descending
        # Does not work because its an object[] array that has no properties for the columns    
        # $Script:dgvResults.DataSource = $analysisResult
        # $Script:dgvResults.Columns["Filename"].Width = 160
        # $Script:dgvResults.Columns["Path"].Visible = $false    
        # $Script:dgvResults.Columns["AnalysisDate"].Visible = $false    
        # Now apply the rule
        $Script:startTime = Get-Date
        $Script:rulesResult = Invoke-XSCopeRule -Rule $currentRule -Codebase $analysisResult
        $Script:endTime = (Get-Date) - $Script:startTime
        $logMsg = "Rules analysis completed for with $($rulesResult.Count) results in {0:f2} seconds" -f $endTime.TotalSeconds
        $Global:logger.LogInfo($logMsg)
        [MessageBox]::Show($logMsg, "Operation status")
        $btnAnalyzeRules.Enabled = $true
        # Attention: The Messagebox might not be visible - it has to be closed before the results are shown in the grid
        # Convert to a DataTable for sorting
        $taResults = ConvertRuleViolationsTo-DataTable -Details $rulesResult
        $bindingSource = [BindingSource]::new()
        $bindingSource.DataSource = $taResults.DefaultView
        $Script:dgvResults.DataSource = $bindingSource
        # $Script:dgvResults.DataSource = $Script:rulesResult
        $Script:dgvResults.Columns["SourcefilePath"].Visible = $False
        $Script:dgvResults.Columns["ElementName"].Visible = $False
        $Script:dgvResults.Columns["RuleName"].Visible = $False
        $Script:dgvResults.Columns["ElementType"].Visible = $False
        # custom sorting
        # $colName = "LOC"
        # [System.Windows.Forms.DataGridViewColumnSortMode]::Automatic
        # $Script:dgvResults.Columns[$colName].SortMode = "Programmatic"

    })

    # Add all controls to the group control
    $grpRules.Controls.Add($btnLoadRuleFile)
    $grpRules.Controls.Add($btnAnalyzeRules)
    $grpRules.Controls.Add($btnUpdateRuleFile)
    $grpRules.Controls.Add($lblXScpRulefilePath)
    $grpRules.Controls.Add($txtRuleContent)

    # Results Group
    $grpResults = [GroupBox]::new()
    $grpResults.Text = "Results"
    $grpResults.Dock = [DockStyle]::Fill

    $Script:dgvResults = [DataGridView]::new()
    $dgvResults.Dock = [DockStyle]::Fill
    $dgvResults.AutoSizeColumnsMode = [DataGridViewAutoSizeColumnsMode]::Fill
    $dgvResults.BackgroundColor = [Color]::LightCyan
    $dgvResults.BorderStyle = [BorderStyle]::Fixed3D
    $dgvResults.AllowUserToAddRows = $false
    $dgvResults.AllowUserToOrderColumns = $true
    $dgvResults.add_CellMouseDoubleClick({
        if ($dgvResults.CurrentCell.OwningColumn.Name -eq "Sourcefile")
        {
            $rowIndex = $dgvResults.CurrentCell.RowIndex
            $sourceFilePath = $dgvResults.Rows[$rowIndex].Cells["SourcefilePath"].Value
            Start-Process -FilePath notepad.exe -ArgumentList $sourceFilePath
        }
    })

    $dgvResults.Add_ColumnHeaderMouseClick({
        param($sender, $eventArgs)
        # Get the index of the clicked column
        # $columnIndex = $eventArgs.ColumnIndex

        # Perform custom sorting logic for the clicked column
        if ($dgvResults.SortOrder -eq "Ascending") {
            # [System.ComponentModel.ListSortDirection]::Descending
            # Sort does not work becasue the DataGridView is bound to a List<T> that does not implement IBindingList
            # two solutions: 1. use a DataTable instead of a List<T> or 2. use a custom sorting
            # $dgvResults.Sort($dgvResults.Columns[$columnIndex], "Descending")
            # $Script:rulesResult = $rulesResult | Sort-Object -Property $dgvResults.Columns[$columnIndex].Name -Descending
        } else {
            # $dgvResults.Sort($dgvResults.Columns[$columnIndex], "Ascending")
            # $Script:rulesResult = $rulesResult | Sort-Object -Property $dgvResults.Columns[$columnIndex].Name
        }
        # $dgvResults.DataSource = $null
        # $dgvResults.DataSource = $rulesResult
    })


    # $dgvResults.Size = [Size]::new(600, 300)
    $dgvResults.Location = [Point]::new(0, 0)

    # Add all controls to the group control
    $grpResults.Controls.Add($dgvResults)

    # Log Group
    $grpLog = [GroupBox]::new()
    $grpLog.Text = "Log"
    $grpLog.Dock = [DockStyle]::Fill

    $Script:lsbLog = [ListBox]::new()
    $lsbLog.Dock = [DockStyle]::Fill
    $lsbLog.BackColor = [Color]::LightYellow
    $lsbLog.Size = [Size]::new(600, 300)
    $lsbLog.Location = [Point]::new(10, 10)

    $lsbLog.add_DoubleClick({
        $sourceFilePath = [Regex]::Match($lsbLog.SelectedItem, 'Analyzing (.*)').Groups[1].Value
        if ($sourceFilePath -ne "") {
            Start-Process -FilePath notepad.exe -ArgumentList $sourceFilePath
        }
    })

    # Add all controls to the group control
    $grpLog.Controls.Add($lsbLog)

    $tabLayout.Controls.Add($grpProject, 0, 0)
    $tabLayout.Controls.Add($grpRules, 0, 1)
    $tabLayout.Controls.Add($grpLog, 0, 2)
    $tabLayout.Controls.Add($grpResults, 0, 3)

    InitButtons

    $Form.Controls.Add($tabLayout)

}

$Form = [Form]::new()
$Form.Text = "XSharpCop V 0.4 (04.10.2024)"
$Form.Size = [Size]::new(1000, 800)
$Form.StartPosition = [FormStartPosition]::CenterScreen
$Form.Add_Load({
    $Psd1Path = Join-Path -Path $PSScriptRoot -ChildPath "Config.psd1"
    $Script:config = Import-PowerShellDataFile -Path $Psd1Path
    if ($Config.LastProjectPath -ne $null) {
        $lblProjectPath.Text = $Config.LastProjectPath
        $Script:XSprojectPath = $Config.LastProjectPath
    }
})

InitializeComponents -Form $Form

[void]$Form.ShowDialog()