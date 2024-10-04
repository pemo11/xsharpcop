<#
 .SYNOPSIS  
 This script is used to test the DataGridView control in PowerShell.
#>

using namespace System.Windows.Forms
using namespace System.Drawing
using namespace System.Collections.Generic

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

class Adress {
    [string]$Street
    [string]$City
    [string]$State
    [string]$Zip

    Adress([string]$Street, [string]$City, [string]$State, [string]$Zip) {
        $this.Street = $Street
        $this.City = $City
        $this.State = $State
        $this.Zip = $Zip
    }
}

$adress1 = [Adress]::new("123 Main St", "Anytown", "NY", "12345")
$adress2 = [Adress]::new("456 Elm St", "Othertown", "CA", "67890")
$adress3 = [Adress]::new("789 Oak St", "Thistown", "TX", "13579")

$adressList = [List[Adress]]::new()
$adressList.Add($adress1)
$adressList.Add($adress2)
$adressList.Add($adress3)

$dgvResults = [DataGridView]::new()
$dgvResults.Dock = [DockStyle]::Fill
$dgvResults.Size = [Size]::new(600, 300)
$dgvResults.Location = [Point]::new(150, 20)

$dgvResults.DataSource = $adressList

$Form = [Form]::new()
$Form.Text = "DataGridView Test"
$Form.Size = [Size]::new(800, 600)
$Form.StartPosition = [FormStartPosition]::CenterScreen

$Form.Controls.Add($dgvResults)

[void]$Form.ShowDialog()