# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a new Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Custom Sorting with ColumnHeaderMouseClick"
$form.Width = 600
$form.Height = 400

# Create a DataGridView control
$gridView = New-Object System.Windows.Forms.DataGridView
$gridView.Dock = [System.Windows.Forms.DockStyle]::Fill
$gridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$gridView.AllowUserToAddRows = $false
$gridView.AllowUserToOrderColumns = $true

# Add columns to the DataGridView
$colName = $gridView.Columns.Add('Name', 'Name')
$colAge = $gridView.Columns.Add('Age', 'Age')
$colCity = $gridView.Columns.Add('City', 'City')

# Set the SortMode of each column to Programmatic to disable automatic sorting
$gridView.Columns[$colName].SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::Programmatic
$gridView.Columns[$colAge].SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::Programmatic
$gridView.Columns[$colCity].SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::Programmatic

# Add some sample data
$gridView.Rows.Add('John Doe', 25, 'New York')
$gridView.Rows.Add('Jane Smith', 30, 'Los Angeles')
$gridView.Rows.Add('Alice Johnson', 22, 'Chicago')
$gridView.Rows.Add('Mike Brown', 35, 'Houston')

# Define the custom sorting logic in the ColumnHeaderMouseClick event
$gridView.Add_ColumnHeaderMouseClick({
    param($sender, $eventArgs)

    # Get the index of the clicked column
    $columnIndex = $eventArgs.ColumnIndex

    # Perform custom sorting logic for the clicked column
    if ($gridView.SortOrder -eq 'Ascending') {
        $gridView.Sort($gridView.Columns[$columnIndex], [System.ComponentModel.ListSortDirection]::Descending)
    } else {
        $gridView.Sort($gridView.Columns[$columnIndex], [System.ComponentModel.ListSortDirection]::Ascending)
    }
})

# Add the DataGridView to the form
$form.Controls.Add($gridView)

# Show the form
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()
