Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ========== CONFIG ==========
$Root = "G:\Scripts"
$Categories = @("Recovery","Performance","Windows","DiskTools","Network","Docker","NAS","Automation","Security")
$AutoSync = "G:\Scripts\Automation\ScriptHub-AutoSync.ps1"
$Dashboard = "G:\Scripts\_ScriptCatcher\ScriptDashboard.html"

# ========== MAIN WINDOW ==========
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZE ScriptHub – Control Center"
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0b1020"

# Title
$labelHeader = New-Object System.Windows.Forms.Label
$labelHeader.Text = "MAZE SCRIPT-HUB CONTROL CENTER"
$labelHeader.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
$labelHeader.ForeColor = "#4dd0e1"
$labelHeader.AutoSize = $true
$labelHeader.Location = New-Object System.Drawing.Point(20,20)
$form.Controls.Add($labelHeader)

# ========== TABS ==========
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(20,70)
$tabs.Size = New-Object System.Drawing.Size(840,450)
$form.Controls.Add($tabs)

foreach ($cat in $Categories) {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $cat
    $tab.BackColor = "#1b2430"

    # Script list
    $list = New-Object System.Windows.Forms.ListBox
    $list.Name = "List_$cat"
    $list.Location = "10,10"
    $list.Size = "650,380"
    $list.BackColor = "#0e1620"
    $list.ForeColor = "#4dd0e1"

    # Populate scripts
    $path = Join-Path $Root $cat
    if (Test-Path $path) {
        $scripts = Get-ChildItem $path -Filter *.ps1 | Select-Object -ExpandProperty FullName
        $list.Items.AddRange($scripts)
    }

    # Run Button
    $btnRun = New-Object System.Windows.Forms.Button
    $btnRun.Text = "Run Script"
    $btnRun.Location = "670,20"
    $btnRun.Size = "140,40"
    $btnRun.BackColor = "#4dd0e1"
    $btnRun.Add_Click({
        if ($list.SelectedItem) {
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$($list.SelectedItem)`""
        }
    })

    # Open Button
    $btnEdit = New-Object System.Windows.Forms.Button
    $btnEdit.Text = "Edit"
    $btnEdit.Location = "670,70"
    $btnEdit.Size = "140,40"
    $btnEdit.BackColor = "#4dd0e1"
    $btnEdit.Add_Click({
        if ($list.SelectedItem) {
            notepad $list.SelectedItem
        }
    })

    $tab.Controls.Add($list)
    $tab.Controls.Add($btnRun)
    $tab.Controls.Add($btnEdit)

    $tabs.TabPages.Add($tab)
}

# ========== SIDEBAR BUTTONS ==========
$btnSync = New-Object System.Windows.Forms.Button
$btnSync.Text = "AutoSync Now"
$btnSync.Location = "20,530"
$btnSync.Size = "130,35"
$btnSync.BackColor = "#4dd0e1"
$btnSync.Add_Click({
    if (Test-Path $AutoSync) {
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$AutoSync`""
    }
})
$form.Controls.Add($btnSync)

$btnDash = New-Object System.Windows.Forms.Button
$btnDash.Text = "Open Dashboard"
$btnDash.Location = "170,530"
$btnDash.Size = "140,35"
$btnDash.BackColor = "#4dd0e1"
$btnDash.Add_Click({
    if (Test-Path $Dashboard) {
        Start-Process $Dashboard
    }
})
$form.Controls.Add($btnDash)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Location = "750,530"
$btnExit.Size = "100,35"
$btnExit.BackColor = "#4dd0e1"
$btnExit.Add_Click({ $form.Close() })
$form.Controls.Add($btnExit)

# ========== RUN APP ==========
[System.Windows.Forms.Application]::Run($form)
