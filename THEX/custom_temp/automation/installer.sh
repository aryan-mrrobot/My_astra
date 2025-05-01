#!/bin/bash

# Function to install Go tools
install_go_tools() {
    go get -u "$1"
}

# Install subfinder
GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder

# Install amass
GO111MODULE=on go install -v github.com/owasp-amass/amass/v4/...@master


# Install httprobe
go get -u github.com/tomnomnom/httprobe

# Install httpx
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx

# Install waybackurls
go get github.com/tomnomnom/waybackurls

# Install gau
GO111MODULE=on go get -u github.com/lc/gau

# Install subover
go get github.com/Ice3man543/subover

# Install Shodan CLI
pip install shodan

# Install Nmap (ensure you have Nmap installed for your specific OS)

# Install nuclei
GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei

echo "Installation completed."
