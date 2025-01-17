# LazyOSINT + Portscan

<p align="center">
  <img src="static/PS1Scripts.gif">
</p>

## Overview
OSINT-lookup is a PowerShell script for automating Open Source Intelligence (OSINT) tasks. It streamlines the process of gathering information about domains and usernames from various online sources.
- Portscan requires WSL instance with NMAP installed. 

## Features
- **Input Interface**: GUI for inputting a domain or a username.
- **Domain Lookup**: Extensive domain searches using Google and specialized services like ViewDNS, web.archive.org, Shodan, etc.
- **Username Lookup**: Searches across social media and online platforms for usernames.
- **Customizable Queries**: Predefined, modifiable queries for different search objectives.

## Requirements
- Windows OS with PowerShell.
- Active internet connection.

## Usage
1. **Run Script**: Execute OSINT-lookup.ps1 in PowerShell.
2. **Input Data**: Choose 'Domain' or 'Username' in the GUI and input the data. For domains, use 'example.com', not 'https://example.com/'.
3. **Start Search**: Click 'OK' to initiate the search.

### If you want to double click it to run...
- If you want to be able to just double click it you will need to make it so windows can launch .ps1 files by double clicking.
1. In a windows CMD (Not powershell) as administrator run the following...
  ```bash
  assoc .ps1=Microsoft.PowerShellScript.1
  ```
  ```bash
  ftype Microsoft.PowerShellScript.1="%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "%1" %*
  ```

## Example Searches
- **Domain**: Enter a domain for a detailed information search from various online resources.
- **Username**: Input a username to find its online presence and activities across platforms.

## Disclaimer
This tool is for educational and ethical use only. Ensure compliance with laws and regulations while using it.

## Contributions
Contributions are welcome. Submit pull requests or issues on GitHub for improvements or new features.


---

**GitHub Repository**: [OSINT-lookup.ps1](https://github.com/pentestfunctions/PowershellPentesting)
