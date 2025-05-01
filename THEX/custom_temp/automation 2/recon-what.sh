#!/bin/bash

# Check if required tools are installed
check_tool() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a tool is missing
missing_tools=()
for tool in "subfinder" "amass" "httprobe" "httpx" "waybackurls" "gau" "subover" "shodan" "nmap"; do
    if ! check_tool "$tool"; then
        missing_tools+=("$tool")
    fi
done

# Check if nuclei is missing
if ! check_tool "nuclei"; then
    echo "Nuclei is not installed. Do you want to install it? (y/n)"
    read -r install_nuclei
    if [ "$install_nuclei" = "y" ]; then
        go get -u github.com/projectdiscovery/nuclei/v2/cmd/nuclei
    fi
fi

# Exit if any required tool is missing
if [ ${#missing_tools[@]} -gt 0 ]; then
    echo "The following tools are missing: ${missing_tools[*]}"
    exit 1
fi

# Ask for the domain
read -p "Enter the domain: " domain

# Create a folder for the domain
output_folder="$domain"
mkdir -p "$output_folder"

# Run subfinder and amass
subfinder -d "$domain" -o "$output_folder/subdomains.txt"
amass enum -d "$domain" -o "$output_folder/subdomains.txt"

# Run httprobe and httpx to find live web servers
cat "$output_folder/subdomains.txt" | httprobe | httpx -silent -o "$output_folder/alive.txt"

# Run waybackurls and gau
cat "$output_folder/subdomains.txt" | waybackurls > "$output_folder/wayback.txt"
cat "$output_folder/subdomains.txt" | gau > "$output_folder/gau_urls.txt"

# Run subover
subover -l "$output_folder/subdomains.txt" -o "$output_folder/takeover.txt"

# Run Shodan to find IPs related to the domain
shodan search "hostname:$domain" > "$output_folder/shodan_ips.txt"

# Run nmap to find open ports
nmap -iL "$output_folder/shodan_ips.txt" -oN "$output_folder/nmap_scan.txt"

# Ask if the user wants to run Nuclei
read -p "Do you want to run Nuclei? (y/n): " use_nuclei

if [ "$use_nuclei" = "y" ]; then
    # Use nuclei to scan the domains
    nuclei -l "$output_folder/subdomains.txt" -t /path/to/nuclei-templates -o "$output_folder/nuclei_results.txt"
fi

# Sort the waybackurls output and check for vulnerabilities
cat "$output_folder/wayback.txt" "$output_folder/gau_urls.txt" | sort -u > "$output_folder/sorted_urls.txt"

# Use gf and gf-patterns to identify potential vulnerabilities
go get -u github.com/tomnomnom/gf
go get -u github.com/1ndianl33t/gf-patterns

# Check for XSS, IDOR, SSRF, CRLF, backup files, parameter pollution vulnerabilities
gf xss "$output_folder/sorted_urls.txt" > "$output_folder/xss_vulns.txt"
gf idor "$output_folder/sorted_urls.txt" > "$output_folder/idor_vulns.txt"
gf ssrf "$output_folder/sorted_urls.txt" > "$output_folder/ssrf_vulns.txt"
gf crlf "$output_folder/sorted_urls.txt" > "$output_folder/crlf_vulns.txt"
gf backup "$output_folder/sorted_urls.txt" > "$output_folder/backup_vulns.txt"
gf pollution "$output_folder/sorted_urls.txt" > "$output_folder/pollution_vulns.txt"

echo "Scanning completed. Check the '$output_folder' directory for output files."
