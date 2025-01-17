Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Net.Http

# Function to download the image
function Download-Image($url, $path) {
    $client = New-Object System.Net.Http.HttpClient
    $response = $client.GetAsync($url).Result
    $bytes = $response.Content.ReadAsByteArrayAsync().Result
    [System.IO.File]::WriteAllBytes($path, $bytes)
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Nmap Scanner by Robot'
$form.Size = New-Object System.Drawing.Size(350,600) # Adjusted size
$form.StartPosition = 'CenterScreen'

# Download and load the image
$imagePath = [System.IO.Path]::GetTempFileName() + ".png"
Download-Image "https://github.com/pentestfunctions/konsole-quickcommands/raw/main/konsole_commands.png" $imagePath

# Load the image
try {
    $image = [System.Drawing.Image]::FromFile($imagePath)
} catch {
    [System.Windows.Forms.MessageBox]::Show("Error loading image", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    return
}

# PictureBox
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Size = New-Object System.Drawing.Size(280, 200)
$pictureBox.Location = New-Object System.Drawing.Point(10, 10)
$pictureBox.SizeMode = 'StretchImage'
$pictureBox.Image = $image
$form.Controls.Add($pictureBox)

# Initial Y position for other controls
$controlY = 220

# Label for domain entry
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, $controlY)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter a domain or IP:'
$form.Controls.Add($label)

# TextBox for domain entry
$controlY += 30
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, $controlY)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

# Remove the CheckedListBox as we will replace it with ListView
$form.Controls.Remove($nmapOptionsCheckedListBox)

# ListView for nmap options with small icons
$controlY += 30
$nmapOptionsListView = New-Object System.Windows.Forms.ListView
$nmapOptionsListView.Location = New-Object System.Drawing.Point(10, $controlY)
$nmapOptionsListView.Size = New-Object System.Drawing.Size(300,150)
$nmapOptionsListView.View = [System.Windows.Forms.View]::Details
$nmapOptionsListView.CheckBoxes = $true
$nmapOptionsListView.Columns.Add('Option', 100)
$nmapOptionsListView.Columns.Add('Info', 50)
$form.Controls.Add($nmapOptionsListView)

# Adding items to ListView
$nmapOptions = @(
    @{Option = '-sV'; Description = 'Version detection'},
    @{Option = '-sC'; Description = 'Default script scanning'},
    @{Option = '-sT'; Description = 'TCP connect scan'},
    @{Option = '-sU'; Description = 'UDP scan'},
    @{Option = '-vv'; Description = 'Increase verbosity level'},
    @{Option = '-A'; Description = 'Aggressive scan options'},
    @{Option = '-O'; Description = 'Enable OS detection'},
    @{Option = '-p'; Description = 'Specify port range'},
    @{Option = '--script'; Description = 'Specify scripts to execute'},
    @{Option = '-Pn'; Description = 'Skip host discovery'},
    @{Option = '--open'; Description = 'Show only open ports'},
    @{Option = '--top-ports 100'; Description = 'Scan top N most common ports'},
    @{Option = '-sS'; Description = 'SYN stealth scan'},
    @{Option = '--traceroute'; Description = 'Perform traceroute'},
    @{Option = '--system-dns'; Description = 'Use system DNS settings'},
    @{Option = '-T4'; Description = 'Set timing template (higher is faster)'}
)


# Adding items to ListView
foreach ($option in $nmapOptions) {
    $item = New-Object System.Windows.Forms.ListViewItem($option.Option)
    $item.SubItems.Add($option.Description)  # Directly display the description
    $nmapOptionsListView.Items.Add($item)
}

# Adjust the column widths to accommodate descriptions
$nmapOptionsListView.Columns[0].Width = 95  # Width for 'Option' column
$nmapOptionsListView.Columns[1].Width = 200  # Increased width for 'Info' column

# Function to show explanations
function ShowExplanation($description) {
    [System.Windows.Forms.MessageBox]::Show($description, 'Option Explanation', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Event handler for ListView item check (to update the command when checkboxes are changed)
$nmapOptionsListView.Add_ItemChecked({
    Update-CurrentCommand
})

# Function to update the current command label
function Update-CurrentCommand {
    $inputText = $textBox.Text
    $nmapOptions = ($nmapOptionsListView.Items | Where-Object { $_.Checked }).ForEach({ $_.Text }) -join ' '

    # Initialize with "nmap" if there are options selected
    $currentCommand = if ($nmapOptions) { "nmap $nmapOptions $inputText" } else { "nmap $inputText" }
    $currentCommandLabel.Text = "Current Command: $currentCommand"
}

# Label for current command
$controlY += 160
$currentCommandLabel = New-Object System.Windows.Forms.Label
$currentCommandLabel.Location = New-Object System.Drawing.Point(10, $controlY)
# Set the width as per requirement. Height is adjusted to accommodate multiple lines.
$currentCommandLabel.Size = New-Object System.Drawing.Size(280, 60) # Adjust the height as needed
$currentCommandLabel.Text = 'Current Command: '
$form.Controls.Add($currentCommandLabel)


# OK and Cancel Buttons
$controlY += 60
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(50, $controlY)
$okButton.Size = New-Object System.Drawing.Size(90,30)
$okButton.Text = 'OK'
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(160, $controlY)
$cancelButton.Size = New-Object System.Drawing.Size(90,30)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

# Event handler for ListView item check (to update the command when checkboxes are changed)
$nmapOptionsListView.Add_ItemCheck({
    # Delay the execution to wait for the check state to update
    Start-Sleep -Milliseconds 10
    Update-CurrentCommand
})

# Function to update the current command label
function Update-CurrentCommand {
    $inputText = $textBox.Text
    $nmapOptions = ($nmapOptionsListView.Items | Where-Object { $_.Checked }).ForEach({ $_.Text }) -join ' '

    $currentCommand = 'nmap ' + $nmapOptions + ' ' + $inputText
    $currentCommandLabel.Text = "Current Command: $currentCommand"
}

# Add text change event to textbox to update current command
$textBox.Add_TextChanged({ Update-CurrentCommand })

$domainRegex = '^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$'
$ipRegex = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
$script:nmapCommandToRun = $null  # Global variable to store the command

$okButton.Add_Click({
    $inputText = $textBox.Text

    if ($inputText -match $domainRegex -or $inputText -match $ipRegex) {
        $nmapOptions = ($nmapOptionsListView.Items | Where-Object { $_.Checked }).ForEach({ $_.Text }) -join ' '
        $script:nmapCommandToRun = "nmap $nmapOptions $inputText"

        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show('Please enter a valid domain or IP address.', 'Invalid Input', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

# Show the form
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $script:nmapCommandToRun) {
    $wslArgs = "-d kali-linux bash -c `"$script:nmapCommandToRun`"; read -p 'Press Enter to exit...'"
    Start-Process "wsl" -ArgumentList $wslArgs
}
