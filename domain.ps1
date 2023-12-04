# Prompt the user for the domain
$domain = Read-Host "Please enter the domain"

# Define the base URL for Google searches
$g_search_base = 'https://www.google.com/search?q='

# Define the list of Google query suffixes
$googleQueries = @(
    '',
    '+intitle:index.of',  # Dir indexing
    '+ext:xml+|+ext:conf+|+ext:cnf+|+ext:reg+|+ext:inf+|+ext:rdp+|+ext:cfg+|+ext:txt+|+ext:ora+|+ext:ini',  # Config files
    '+ext:sql+|+ext:dbf+|+ext:mdb',  # Database files
    '+ext:log',  # Logs
    '+ext:bkf+|+ext:bkp+|+ext:bak+|+ext:old+|+ext:backup',  # Backups
    '+intext:"sql syntax near"+|+intext:"syntax error has occurred"+|+intext:"incorrect syntax near"+|+intext:"unexpected end of SQL command"+|+intext:"Warning: mysql_connect()"+|+intext:"Warning: mysql_query()"+|+intext:"Warning: pg_connect()"',  # SQL errors
    '+filetype:asmx+|+inurl:jws?wsdl+|+filetype:jws+|+inurl:asmx?wsdl',  # WSDLs
    '+ext:doc+|+ext:docx+|+ext:odt+|+ext:pdf+|+ext:rtf+|+ext:sxw+|+ext:psw+|+ext:ppt+|+ext:pptx+|+ext:pps+|+ext:csv'  # Docs
)

# Generate URLs for Google queries
$urls = foreach ($query in $googleQueries) {
    "$g_search_base" + "site:$domain" + $query
}

# Add specific Google search URLs for Pastebin
$urls += "$g_search_base" + "site:pastebin.com+$domain"
$urls += "$g_search_base" + "site:pastebin.com+`"$domain`""

# Define additional URLs for various tools and services
$additionalUrls = @(
    "https://viewdns.info/reverseip/?host=$domain&t=1",
    "https://viewdns.info/iphistory/?domain=$domain",
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

# Combine all URLs
$allUrls = $urls + $additionalUrls

# Open each URL in the default browser
foreach ($url in $allUrls) {
    Start-Process $url
}
