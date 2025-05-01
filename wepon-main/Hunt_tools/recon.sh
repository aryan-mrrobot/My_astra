#!/bin/bash

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go first."
    exit 1
fi

# Array of Go tools to install
declare -A gotools=(
    ["gf"]="go install -v github.com/tomnomnom/gf@latest"
    ["brutespray"]="go install -v github.com/x90skysn3k/brutespray@latest"
    ["qsreplace"]="go install -v github.com/tomnomnom/qsreplace@latest"
    ["ffuf"]="go install -v github.com/ffuf/ffuf/v2@latest"
    ["github-subdomains"]="go install -v github.com/gwen001/github-subdomains@latest"
    ["gitlab-subdomains"]="go install -v github.com/gwen001/gitlab-subdomains@latest"
    ["nuclei"]="go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    ["anew"]="go install -v github.com/tomnomnom/anew@latest"
    ["notify"]="go install -v github.com/projectdiscovery/notify/cmd/notify@latest"
    ["unfurl"]="go install -v github.com/tomnomnom/unfurl@v0.3.0"
    ["httpx"]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
    ["github-endpoints"]="go install -v github.com/gwen001/github-endpoints@latest"
    ["dnsx"]="go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    ["subjs"]="go install -v github.com/lc/subjs@latest"
    ["Gxss"]="go install -v github.com/KathanP19/Gxss@latest"
    ["katana"]="go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
    ["crlfuzz"]="go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
    ["dalfox"]="go install -v github.com/hahwul/dalfox/v2@latest"
    ["puredns"]="go install -v github.com/d3mondev/puredns/v2@latest"
    ["interactsh-client"]="go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    ["analyticsrelationships"]="go install -v github.com/Josue87/analyticsrelationships@latest"
    ["gotator"]="go install -v github.com/Josue87/gotator@latest"
    ["roboxtractor"]="go install -v github.com/Josue87/roboxtractor@latest"
    ["mapcidr"]="go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"
    ["cdncheck"]="go install -v github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest"
    ["dnstake"]="go install -v github.com/pwnesia/dnstake/cmd/dnstake@latest"
    ["tlsx"]="go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
    ["gitdorks_go"]="go install -v github.com/damit5/gitdorks_go@latest"
    ["smap"]="go install -v github.com/s0md3v/smap/cmd/smap@latest"
    ["dsieve"]="go install -v github.com/trickest/dsieve@master"
    ["inscope"]="go install -v github.com/tomnomnom/hacks/inscope@latest"
    ["enumerepo"]="go install -v github.com/trickest/enumerepo@latest"
    ["Web-Cache-Vulnerability-Scanner"]="go install -v github.com/Hackmanit/Web-Cache-Vulnerability-Scanner@latest"
    ["subfinder"]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    ["hakip2host"]="go install -v github.com/hakluke/hakip2host@latest"
    ["gau"]="go install -v github.com/lc/gau/v2/cmd/gau@latest"
    ["mantra"]="go install -v github.com/MrEmpy/mantra@latest"
    ["crt"]="go install -v github.com/cemulus/crt@latest"
    ["s3scanner"]="go install -v github.com/sa7mon/s3scanner@latest"
    ["nmapurls"]="go install -v github.com/sdcampbell/nmapurls@latest"
    ["shortscan"]="go install -v github.com/bitquark/shortscan/cmd/shortscan@latest"
    ["sns"]="go install github.com/sw33tLie/sns@latest"
    ["ppmap"]="go install -v github.com/kleiton0x00/ppmap@latest"
    ["sourcemapper"]="go install -v github.com/denandz/sourcemapper@latest"
    ["jsluice"]="go install -v github.com/BishopFox/jsluice/cmd/jsluice@latest"
    ["waybackurls"]="go install -v github.com/tomnomnom/waybackurls@latest"
    ["waymore"]="go install -v github.com/xnl-h4ck3r/waymore/cmd/waymore@latest"
)

# Function to display loading animation
loading_animation() {
    local tool="$1"
    echo -n "Installing $tool "
    for i in {1..3}; do
        echo -n "."
        sleep 0.5
    done
    echo ""
}

# Install each Go tool
for tool in "${!gotools[@]}"; do
    # Check if the tool is already installed
    if command -v "$tool" &> /dev/null; then
        echo "$tool is already installed."
    else
        loading_animation "$tool"
        # Suppress output while installing
        eval "${gotools[$tool]} > /dev/null 2>&1"
        if [ $? -eq 0 ]; then
            # Move the binary to /usr/local/bin with sudo
            sudo mv "$HOME/go/bin/$tool" /usr/local/bin/ > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "$tool installed successfully and moved to /usr/local/bin."
            else
                echo "Failed to move $tool to /usr/local/bin. Please check permissions."
            fi
        else
            echo "Failed to install $tool. Please check your internet connection or Go environment."
        fi
    fi
done

echo "All installations completed."
