# ============================================================
# MAZE SCRIPT-HUB PRO v6.1  (FULL SINGLE-FILE VERSION)
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -------------------- CONFIG --------------------
$Root        = "G:\Scripts"
$PluginRoot  = Join-Path $Root "Plugins"
$Categories  = @("Recovery","Performance","Windows","DiskTools","Network","Docker","NAS","Automation","Security")

# -------------------- MAIN FORM --------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZE ScriptHub – DevOps Control Center"
$form.Size = New-Object System.Drawing.Size(1150,780)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0b1020"
$form.KeyPreview = $true

# -------------------- HEADER --------------------
$header = New-Object System.Windows.Forms.Label
$header.Text = "MAZE SCRIPT-HUB PRO v6.1"
$header.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
$header.ForeColor = "#4dd0e1"
$header.AutoSize = $true
$header.Location = New-Object System.Drawing.Point(20,10)
$form.Controls.Add($header)

# -------------------- THEME TOGGLE --------------------
$btnDark = New-Object Windows.Forms.Button
$btnDark.Text = "Dark"
$btnDark.Location = New-Object System.Drawing.Point(650,15)
$btnDark.Size = New-Object System.Drawing.Size(60,30)
$btnDark.BackColor = "#1b2430"
$btnDark.ForeColor = "White"
$btnDark.Add_Click({
    $form.BackColor = "#0b1020"
    $outputBox.BackColor = "Black"
    $outputBox.ForeColor = "#4dd0e1"
    $aiBox.BackColor = "#111111"
    $aiBox.ForeColor = "#00ffaa"
})
$form.Controls.Add($btnDark)

$btnLight = New-Object Windows.Forms.Button
$btnLight.Text = "Light"
$btnLight.Location = New-Object System.Drawing.Point(720,15)
$btnLight.Size = New-Object System.Drawing.Size(60,30)
$btnLight.BackColor = "White"
$btnLight.ForeColor = "Black"
$btnLight.Add_Click({
    $form.BackColor = "WhiteSmoke"
    $outputBox.BackColor = "White"
    $outputBox.ForeColor = "Black"
    $aiBox.BackColor = "White"
    $aiBox.ForeColor = "Black"
})
$form.Controls.Add($btnLight)

# -------------------- TABS --------------------
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(20,60)
$tabs.Size = New-Object System.Drawing.Size(620,660)
$form.Controls.Add($tabs)

# -------------------- OUTPUT CONSOLE --------------------
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.BackColor = "Black"
$outputBox.ForeColor = "#4dd0e1"
$outputBox.Font = New-Object System.Drawing.Font("Consolas",10)
$outputBox.Size = New-Object System.Drawing.Size(460,560)
$outputBox.Location = New-Object System.Drawing.Point(660,60)
$form.Controls.Add($outputBox)

# -------------------- AI HELPER PANEL --------------------
$aiBox = New-Object System.Windows.Forms.TextBox
$aiBox.Multiline = $true
$aiBox.ScrollBars = "Vertical"
$aiBox.BackColor = "#111111"
$aiBox.ForeColor = "#00ffaa"
$aiBox.Font = New-Object System.Drawing.Font("Consolas",9)
$aiBox.Size = New-Object System.Drawing.Size(460,120)
$aiBox.Location = New-Object System.Drawing.Point(660,200)
$aiBox.Text = "AI Helper Panel Loaded.`r`n(Connect API later.)"
$form.Controls.Add($aiBox)

$aiInput = New-Object System.Windows.Forms.TextBox
$aiInput.Location = New-Object System.Drawing.Point(660,330)
$aiInput.Size = New-Object System.Drawing.Size(350,25)
$form.Controls.Add($aiInput)

$btnAI = New-Object System.Windows.Forms.Button
$btnAI.Text = "Ask AI (stub)"
$btnAI.Location = New-Object System.Drawing.Point(1020,330)
$btnAI.Size = New-Object System.Drawing.Size(100,25)
$btnAI.BackColor = "#4dd0e1"
$btnAI.Add_Click({
    $aiBox.AppendText("You: $($aiInput.Text)`r`nAI: (API not connected).`r`n`r`n")
})
$form.Controls.Add($btnAI)

# -------------------- SYSTEM MONITOR --------------------
$sysPanel = New-Object System.Windows.Forms.GroupBox
$sysPanel.Text = "System Monitor"
$sysPanel.ForeColor = "#4dd0e1"
$sysPanel.Size = New-Object System.Drawing.Size(460,140)
$sysPanel.Location = New-Object System.Drawing.Point(660,380)
$form.Controls.Add($sysPanel)

$lblCPU = New-Object System.Windows.Forms.Label
$lblCPU.Text = "CPU: Loading..."
$lblCPU.ForeColor = "White"
$lblCPU.AutoSize = $true
$lblCPU.Location = New-Object System.Drawing.Point(15,25)
$sysPanel.Controls.Add($lblCPU)

$lblRAM = New-Object System.Windows.Forms.Label
$lblRAM.Text = "RAM: Loading..."
$lblRAM.ForeColor = "White"
$lblRAM.AutoSize = $true
$lblRAM.Location = New-Object System.Drawing.Point(15,55)
$sysPanel.Controls.Add($lblRAM)

$lblNET = New-Object System.Windows.Forms.Label
$lblNET.Text = "Network: Loading..."
$lblNET.ForeColor = "White"
$lblNET.AutoSize = $true
$lblNET.Location = New-Object System.Drawing.Point(15,85)
$sysPanel.Controls.Add($lblNET)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average

        $os = Get-CimInstance Win32_OperatingSystem
        $total = [math]::Round($os.TotalVisibleMemorySize/1MB,2)
        $free  = [math]::Round($os.FreePhysicalMemory/1MB,2)
        $used  = $total - $free

        $netstats = Get-NetAdapterStatistics -ErrorAction SilentlyContinue
        if ($netstats) {
            $net = $netstats | Measure-Object ReceivedBytes,SentBytes -Sum
            $rx = [math]::Round(($net.Sum.ReceivedBytes/1MB),2)
            $tx = [math]::Round(($net.Sum.SentBytes/1MB),2)
            $lblNET.Text = "Network: RX $rx MB | TX $tx MB"
        }

        $lblCPU.Text = "CPU: $cpu%"
        $lblRAM.Text = "RAM: $used GB / $total GB"
    } catch {}
})
$timer.Start()

# -------------------- COMMAND BUTTONS --------------------
# Clear
$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear Output"
$btnClear.Location = New-Object System.Drawing.Point(660,650)
$btnClear.Size = New-Object System.Drawing.Size(120,35)
$btnClear.BackColor = "#4dd0e1"
$btnClear.Add_Click({ $outputBox.Clear() })
$form.Controls.Add($btnClear)

# Save
$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = "Save Output"
$btnSave.Location = New-Object System.Drawing.Point(790,650)
$btnSave.Size = New-Object System.Drawing.Size(120,35)
$btnSave.BackColor = "#4dd0e1"
$btnSave.Add_Click({
    $logDir = Join-Path $Root "Logs"
    if (!(Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }
    $file = Join-Path $logDir ("Output-{0}.txt" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
    $outputBox.Text | Out-File $file
    [System.Windows.Forms.MessageBox]::Show("Saved: $file")
})
$form.Controls.Add($btnSave)

# AutoSync
$btnSync = New-Object System.Windows.Forms.Button
$btnSync.Text = "AutoSync"
$btnSync.Location = New-Object System.Drawing.Point(920,650)
$btnSync.Size = New-Object System.Drawing.Size(120,35)
$btnSync.BackColor = "#4dd0e1"
$btnSync.Add_Click({
    $sync = Join-Path $Root "Automation\ScriptHub-AutoSync.ps1"
    if (Test-Path $sync) {
        $outputBox.AppendText("Running AutoSync…`r`n")
        powershell -ExecutionPolicy Bypass -File $sync | ForEach-Object {
            $outputBox.AppendText($_ + "`r`n")
        }
    } else {
        $outputBox.AppendText("AutoSync not found.`r`n")
    }
})
$form.Controls.Add($btnSync)

# Dashboard
$btnDash = New-Object System.Windows.Forms.Button
$btnDash.Text = "Dashboard"
$btnDash.Location = New-Object System.Drawing.Point(660,690)
$btnDash.Size = New-Object System.Drawing.Size(380,35)
$btnDash.BackColor = "#4dd0e1"
$btnDash.Add_Click({
    $dash = Join-Path $Root "ScriptDashboard.html"
    if (Test-Path $dash) { Start-Process $dash }
    else { $outputBox.AppendText("Dashboard not found.`r`n") }
})
$form.Controls.Add($btnDash)

# -------------------- REMOTE EXECUTION (STUB) --------------------
$lblRemote = New-Object System.Windows.Forms.Label
$lblRemote.Text = "Remote Host:"
$lblRemote.ForeColor = "#4dd0e1"
$lblRemote.AutoSize = $true
$lblRemote.Location = New-Object System.Drawing.Point(660,155)
$form.Controls.Add($lblRemote)

$txtRemote = New-Object System.Windows.Forms.TextBox
$txtRemote.Location = New-Object System.Drawing.Point(760,150)
$txtRemote.Size = New-Object System.Drawing.Size(120,25)
$form.Controls.Add($txtRemote)

$btnRemote = New-Object System.Windows.Forms.Button
$btnRemote.Text = "Run Remote (stub)"
$btnRemote.Location = New-Object System.Drawing.Point(890,150)
$btnRemote.Size = New-Object System.Drawing.Size(150,25)
$btnRemote.BackColor = "#4dd0e1"
$btnRemote.Add_Click({
    if (-not $txtRemote.Text) {
        $outputBox.AppendText("No remote host entered.`r`n")
        return
    }
    $outputBox.AppendText("Would run on remote host: $($txtRemote.Text)`r`n(Remoting not yet wired).`r`n")
})
$form.Controls.Add($btnRemote)

# -------------------- SCRIPT RUNNER --------------------
function Run-WithOutput {
    param([string]$ScriptPath)

    if (-not (Test-Path $ScriptPath)) {
        $outputBox.AppendText("Script not found: $ScriptPath`r`n")
        return
    }

    $outputBox.Clear()
    $outputBox.AppendText("Running: $ScriptPath`r`n`r`n")

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$ScriptPath`""
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $proc.Start() | Out-Null

    while (-not $proc.HasExited) {
        $line = $proc.StandardOutput.ReadLine()
        if ($line) { $outputBox.AppendText($line + "`r`n") }
    }

    $err = $proc.StandardError.ReadToEnd()
    if ($err) { $outputBox.AppendText("ERROR:`r`n$err`r`n") }

    $outputBox.AppendText("`r`n=== Script Complete ===`r`n")
}

# -------------------- CATEGORY TABS --------------------
foreach ($cat in $Categories) {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $cat
    $tab.BackBackColor = "#1b2430"

    $list = New-Object System.Windows.Forms.ListBox
    $list.Location = New-Object System.Drawing.Point(10,10)
    $list.Size     = New-Object System.Drawing.Size(580,520)
    $list.BackColor = "#0e1620"
    $list.ForeColor = "#4dd0e1"
    $scripts = Get-ChildItem (Join-Path $Root $cat) -Filter *.ps1 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    if ($scripts) { $list.Items.AddRange($scripts) }

    $btnRun = New-Object System.Windows.Forms.Button
    $btnRun.Text = "Run"
    $btnRun.Location = New-Object System.Drawing.Point(10,540)
    $btnRun.Size = New-Object System.Drawing.Size(120,35)
    $btnRun.BackColor = "#4dd0e1"
    $btnRun.Add_Click({
        if ($list.SelectedItem) { Run-WithOutput $list.SelectedItem }
    })

    $btnEdit = New-Object System.Windows.Forms.Button
    $btnEdit.Text = "Edit"
    $btnEdit.Location = New-Object System.Drawing.Point(150,540)
    $btnEdit.Size = New-Object System.Drawing.Size(120,35)
    $btnEdit.BackColor = "#4dd0e1"
    $btnEdit.Add_Click({
        if ($list.SelectedItem) { notepad $list.SelectedItem }
    })

    $tab.Controls.Add($list)
    $tab.Controls.Add($btnRun)
    $tab.Controls.Add($btnEdit)
    $tabs.TabPages.Add($tab)
}

# -------------------- PLUGIN TABS --------------------
if (Test-Path $PluginRoot) {
    foreach ($p in Get-ChildItem $PluginRoot -Directory) {
        $tab = New-Object System.Windows.Forms.TabPage
        $tab.Text = "Plugin: " + $p.Name
        $tab.BackColor = "#1b2430"

        $list = New-Object System.Windows.Forms.ListBox
        $list.Location = New-Object System.Drawing.Point(10,10)
        $list.Size     = New-Object System.Drawing.Size(580,520)
        $list.BackColor = "#0e1620"
        $list.ForeColor = "#4dd0e1"
        $scripts = Get-ChildItem $p.FullName -Filter *.ps1 -File | Select-Object -ExpandProperty FullName
        if ($scripts) { $list.Items.AddRange($scripts) }

        $btnRun = New-Object System.Windows.Forms.Button
        $btnRun.Text = "Run"
        $btnRun.Location = New-Object System.Drawing.Point(10,540)
        $btnRun.Size = New-Object System.Drawing.Size(120,35)
        $btnRun.BackColor = "#4dd0e1"
        $btnRun.Add_Click({
            if ($list.SelectedItem) { Run-WithOutput $list.SelectedItem }
        })

        $btnEdit = New-Object System.Windows.Forms.Button
        $btnEdit.Text = "Edit"
        $btnEdit.Location = New-Object System.Drawing.Point(150,540)
        $btnEdit.Size = New-Object System.Drawing.Size(120,35)
        $btnEdit.BackColor = "#4dd0e1"
        $btnEdit.Add_Click({
            if ($list.SelectedItem) { notepad $list.SelectedItem }
        })

        $tab.Controls.Add($list)
        $tab.Controls.Add($btnRun)
        $tab.Controls.Add($btnEdit)
        $tabs.TabPages.Add($tab)
    }
}

# -------------------- FAVORITES --------------------
$favTab = New-Object System.Windows.Forms.TabPage
$favTab.Text = "⭐ Favorites"
$favTab.BackColor = "#1b2430"

$favList = New-Object System.Windows.Forms.ListBox
$favList.Location = New-Object System.Drawing.Point(10,10)
$favList.Size     = New-Object System.Drawing.Size(580,520)
$favList.BackColor = "#0e1620"
$favList.ForeColor = "#ffcc00"
$favTab.Controls.Add($favList)

$btnAddFav = New-Object System.Windows.Forms.Button
$btnAddFav.Text = "Add to Favorites"
$btnAddFav.Location = New-Object System.Drawing.Point(10,540)
$btnAddFav.Size = New-Object System.Drawing.Size(150,35)
$btnAddFav.BackColor = "#ffcc00"
$btnAddFav.Add_Click({
    $activeTab = $tabs.SelectedTab
    if ($activeTab -eq $favTab) { return }
    $list = $activeTab.Controls | Where-Object { $_ -is [System.Windows.Forms.ListBox] } | Select-Object -First 1
    if ($list -and $list.SelectedItem -and -not $favList.Items.Contains($list.SelectedItem)) {
        $favList.Items.Add($list.SelectedItem)
    }
})
$favTab.Controls.Add($btnAddFav)

$btnRunFav = New-Object System.Windows.Forms.Button
$btnRunFav.Text = "Run Favorite"
$btnRunFav.Location = New-Object System.Drawing.Point(170,540)
$btnRunFav.Size = New-Object System.Drawing.Size(150,35)
$btnRunFav.BackColor = "#4dd0e1"
$btnRunFav.Add_Click({
    if ($favList.SelectedItem) { Run-WithOutput $favList.SelectedItem }
})
$favTab.Controls.Add($btnRunFav)

$tabs.TabPages.Add($favTab)

# -------------------- HOTKEYS --------------------
$form.Add_KeyDown({
    switch ($_.KeyCode) {
        "F5" {
            $activeTab = $tabs.SelectedTab
            $list = $activeTab.Controls | Where-Object { $_ -is [System.Windows.Forms.ListBox] } | Select-Object -First 1
            if ($list.SelectedItem) { Run-WithOutput $list.SelectedItem }
        }
        "F6" { $outputBox.Clear() }
        "F7" {
            $sync = Join-Path $Root "Automation\ScriptHub-AutoSync.ps1"
            if (Test-Path $sync) {
                Start-Process "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$sync`""
            }
        }
    }
})

# -------------------- RUN --------------------
[System.Windows.Forms.Application]::Run($form)
