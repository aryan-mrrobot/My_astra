#!/bin/bash

# Install necessary packages and dependencies

# Install waybackurls
 go install github.com/tomnomnom/waybackurls@latest

# Install waymore
 go install github.com/j3ssie/go-auxs/waymore@latest

# Install subfinder
 go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Install findomain
git clone https://github.com/Edu4rdSHL/findomain.git /opt/findomain
cd /opt/findomain
cargo build --release
cp target/release/findomain /usr/bin/

# Install nuclei
 go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Install ffuf
 go install github.com/ffuf/ffuf@latest

# Install kxss
 go install github.com/Emoe/kxss@latest

# Install kxss
 go install github.com/Emoe/kxss@latest

# Install openredirex
 go install github.com/devanshbatham/openredirex@latest

# Install xsscrapy
git clone https://github.com/DanMcInerney/xsscrapy.git /opt/xsscrapy

# Install corsy
git clone https://github.com/s0md3v/Corsy.git /opt/Corsy

# Install XSStrike
git clone https://github.com/s0md3v/XSStrike.git /opt/XSStrike

# Install SQLMap
apt-get install sqlmap

# Install cloud_enum
 go install github.com/initstring/cloud_enum@latest

# Print completion message
echo "Setup completed successfully."
