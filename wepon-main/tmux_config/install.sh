#!/bin/bash

# ASCII Art Header
cat << "EOF"
   _____                                __________       .__    .__  __   
  /  _  \_______ ___.__._____    ____   \______   \ ____ |  |__ |__|/  |_ 
 /  /_\  \_  __ <   |  |\__  \  /    \   |       _//  _ \|  |  \|  \   __\
/    |    \  | \/\___  | / __ \|   |  \  |    |   (  <_> )   Y  \  ||  |  
\____|__  /__|   / ____|(____  /___|  /  |____|_  /\____/|___|  /__||__|
EOF

requirements="[+] Downloading requirements..."

for ((i=0; i<${#requirements}; i++)); do
    echo -n "${requirements:$i:1}"
    sleep 0.05
done
echo

sudo apt install -y tmux xclip dconf-cli

setup="[+] Setting up gladiator tmux config..."
for ((i=0; i<${#setup}; i++)); do
    echo -n "${setup:$i:1}"
    sleep 0.05
done
echo

cp gladiator_tmux.conf ~/.tmux.conf
mkdir -p ~/Scripts
cp vpnIP_VM.sh ~/Scripts/vpnIP_VM.sh
chmod +x ~/Scripts/vpnIP_VM.sh

tmux_plugin="[+] Adding tmux plugin manager..."
for ((i=0; i<${#tmux_plugin}; i++)); do
    echo -n "${tmux_plugin:$i:1}"
    sleep 0.05
done
echo

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "Press Prefix+I inside tmux to install the plugins"

icons_install="[+] Installing icons in terminal..."
for ((i=0; i<${#icons_install}; i++)); do
    echo -n "${icons_install:$i:1}"
    sleep 0.05
done
echo

cd ~/ 
git clone https://github.com/sebastiencs/icons-in-terminal.git
cd icons-in-terminal
chmod +x install.sh
./install.sh

setup_done="[-] Done!"
for ((i=0; i<${#setup_done}; i++)); do
    echo -n "${setup_done:$i:1}"
    sleep 0.05
done
echo

exit_txt="Exiting Script Now..."
for ((i=0; i<${#exit_txt}; i++)); do
    echo -n "${exit_txt:$i:1}"
    sleep 0.05
done
echo

echo "Open a new terminal for the changes to take effect."
