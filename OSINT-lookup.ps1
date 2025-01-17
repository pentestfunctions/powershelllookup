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
$form.Text = 'LazyOSINT by Robot'
$form.Size = New-Object System.Drawing.Size(310,400) # Adjusted size to accommodate all controls
$form.StartPosition = 'CenterScreen'

# Download and load the image
$imagePath = [System.IO.Path]::GetTempFileName() + ".png"
Download-Image "https://github.com/pentestfunctions/konsole-quickcommands/raw/main/konsole_commands.png" $imagePath

try {
    $image = [System.Drawing.Image]::FromFile($imagePath)
} catch {
    [System.Windows.Forms.MessageBox]::Show("Error loading image", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    return
}

$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Size = New-Object System.Drawing.Size(280, 200)
$pictureBox.Location = New-Object System.Drawing.Point(10, 10)
$pictureBox.SizeMode = 'StretchImage'
$pictureBox.Image = $image
$form.Controls.Add($pictureBox)

# Adjust the location of other controls
$controlY = 220 # Starting Y position for the controls below the image

# Create label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, $controlY)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter a domain or username:'
$form.Controls.Add($label)

# Adjust Y position for next control
$controlY += 30

# Create textbox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, $controlY)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

# Adjust Y position for next control
$controlY += 30

# Create combobox
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(10, $controlY)
$comboBox.Size = New-Object System.Drawing.Size(260,21)
$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBox.Items.Add('Domain')
$comboBox.Items.Add('Username')
$comboBox.SelectedIndex = 0
$form.Controls.Add($comboBox)

# Adjust Y position for next control
$controlY += 40

# Create OK and Cancel buttons
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

# OK Button event handler
$okButton.Add_Click({
    $inputText = $textBox.Text
    $selectedType = $comboBox.SelectedItem.ToString()

    if (($selectedType -eq 'Domain' -and $inputText -match $domainRegex) -or 
        ($selectedType -eq 'Username')) {
        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    } else {
        $errorMessage = if ($selectedType -eq 'Domain') { 'Please enter a valid domain without http:// or https:// and with a TLD.' } else { 'Please enter a valid username.' }
        [System.Windows.Forms.MessageBox]::Show($errorMessage, 'Invalid Input', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

# Regex patterns for validation
$domainRegex = '^(?!https?://)([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$'

$form.Topmost = $true

# Show the form
$result = $form.ShowDialog()

# Cleanup: delete the downloaded image file
Remove-Item $imagePath -ErrorAction SilentlyContinue

# Function to create dork URLs for username
function Create-DorkUrls {
    param ([string]$username)
    $dorks = @(
        '',
        "+intitle:`"$username`"",
        "+inurl:`"$username`"",
        "site:socialnetworksite.com `"$username`"",
        "`"$username`"",
        "intitle:`"$username`"",
        "inurl:`"$username`"",
        "site:twitter.com `"$username`"",
        "site:facebook.com `"$username`"",
        "$username + location",
        "$username + hobbies",
        "`"$username`" + email",
        "`"$username`" + bio",
        "filetype:pdf `"$username`"",
        "filetype:doc `"$username`"",
        "$username + comments",
        "$username + posts",
        "$username + profile",
        "$username + photos",
        "$username + videos"
    )
    $dorkUrls = foreach ($dork in $dorks) {
        "$g_search_base$dork"
    }
    return $dorkUrls
}

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $inputType = $comboBox.SelectedItem
    $inputValue = $textBox.Text

    # Define the base URL for Google searches
    $g_search_base = 'https://www.google.com/search?q='

    if ($inputType -eq 'Domain') {
        $domain = $inputValue

        # Domain-specific operations
        $googleQueries = @(
            '',
            '+intitle:index.of',
            '+ext:xml+|+ext:conf+|+ext:cnf+|+ext:reg+|+ext:inf+|+ext:rdp+|+ext:cfg+|+ext:txt+|+ext:ora+|+ext:ini',
            '+ext:sql+|+ext:dbf+|+ext:mdb',
            '+ext:log',
            '+ext:bkf+|+ext:bkp+|+ext:bak+|+ext:old+|+ext:backup',
            '+intext:"sql syntax near"+|+intext:"syntax error has occurred"+|+intext:"incorrect syntax near"+|+intext:"unexpected end of SQL command"+|+intext:"Warning: mysql_connect()"+|+intext:"Warning: mysql_query()"+|+intext:"Warning: pg_connect()"',
            '+filetype:asmx+|+inurl:jws?wsdl+|+filetype:jws+|+inurl:asmx?wsdl',
            '+ext:doc+|+ext:docx+|+ext:odt+|+ext:pdf+|+ext:rtf+|+ext:sxw+|+ext:psw+|+ext:ppt+|+ext:pptx+|+ext:pps+|+ext:csv'
        )

        $urls = foreach ($query in $googleQueries) {
            "$g_search_base" + "site:$domain" + $query
        }

        $urls += "$g_search_base" + "site:pastebin.com+$domain"
        $urls += "$g_search_base" + "site:pastebin.com+`"$domain`""

        $additionalUrls = @(
            "https://viewdns.info/reverseip/?host=$domain&t=1",
            "https://viewdns.info/iphistory/?domain=$domain",
            "https://viewdns.info/httpheaders/?domain=$domain",
            "https://web.archive.org/cdx/search/cdx?url=*.$domain&output=xml&fl=original&collapse=urlkey",
            "https://web.archive.org/web/20230000000000*/$domain",
            "https://viewdns.info/dnsrecord/?domain=$domain",
            "https://viewdns.info/portscan/?host=$domain",
            "https://crt.sh/?q=$domain",
            "https://who.is/whois/$domain",
            "https://securitytrails.com/list/apex_domain/$domain",
            "https://urlscan.io/search/#$domain",
            "https://www.shodan.io/search?query=$domain",
            "https://search.censys.io/search?resource=hosts&sort=RELEVANCE&per_page=25&virtual_hosts=EXCLUDE&q=$domain",
            "https://dnshistory.org/dns-records/$domain",
            "https://www.wappalyzer.com/lookup/$domain/",
            "https://builtwith.com/$domain",
            "https://sitereport.netcraft.com/?url=http://$domain",
            "https://www.statscrop.com/www/$domain",
            "https://spyonweb.com/$domain",
            "https://securityheaders.com/?q=$domain&followRedirects=on",
            "https://github.com/search?q=$domain&type=code",
            "https://grep.app/search?q=$domain",
            "https://trends.google.com/trends/explore?q=$domain",
            "https://dnssec-debugger.verisignlabs.com/$domain",
            "https://dnsviz.net/d/$domain/analyze/",
            "https://buckets.grayhatwarfare.com/files?keywords=$domain"
        )

        $allUrls = $urls + $additionalUrls

        foreach ($url in $allUrls) {
            Start-Process $url
        }
    } elseif ($inputType -eq 'Username') {
        $username = $inputValue
        
        # Generate dork URLs
        $dorkUrls = Create-DorkUrls -username $username
        
        # Open each dork URL in a browser
        foreach ($url in $dorkUrls) {
            Start-Process $url
        }

        # Username-specific operations
        $socialMediaSites = @(
            "https://twitter.com/$username",
            "https://www.tiktok.com/@$username",
            "https://disqus.com/by/$username",
            "https://instagram.com/$username",
            "https://www.pinterest.com/$username",
            "https://facebook.com/$username",
            "https://patreon.com/$username",
            "https://imgur.com/user/$username",
            "https://pastebin.com/u/$username",
            "https://reddit.com/user/$username",
            "https://twitch.tv/$username",
            "https://fiverr.com/$username",
            "https://ask.fm/$username",
            "https://medium.com/@$username",
            "https://github.com/$username",
            "https://github.com/search?q=$username&type=repositories",
            "https://flickr.com/people/$username",
            "https://themeforest.net/user/$username",
            "https://myspace.com/$username",
            "https://www.searchblogspot.com/search?q=$username",
            "https://www.kickstarter.com/profile/$username",
            "https://about.me/$username",
            "https://deviantart.com/$username",
            "https://www.reverbnation.com/$username",
            "https://www.behance.net/$username",
            "https://buzzfeed.com/$username",
            "https://soundcloud.com/$username",
            "https://tumblr.com/$username",
            "https://grep.app/search?q=$username",
            "$username.newgrounds.com",
            "$username.bandcamp.com/",
            "https://youtube.com/@$username",
            "https://search.0t.rocks/records?usernames=$username"
        )

        foreach ($url in $socialMediaSites) {
            Start-Process $url
        }
    }
} else {
    Write-Error "Operation cancelled or no input provided."
    exit
}
