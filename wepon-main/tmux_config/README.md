# My Tmux Configuration

### Features:
1. Show VPN IP address in the status bar when connected to VPN.
2. Supports mouse functions. Mouse clicks can be used to switch splits, windows, sessions, etc. Scrolling with the mouse wheel activates copy mode, allowing selection with the mouse cursor.

### Update (21/10/2024):
- Cleaned up the configuration; it was a homemade noodle soup before, now it's like out of a restaurant noodle soup.
- Updated colors and added tmux plugins.
- Removed the bashrc as it was overwriting the user's bashrc.

### Potential TODO:
- I believe my color choices can be boring at times, so feel free to send a PR if you have a better color scheme.

### Screenshots:
Default look with Tunnel and SSH scripts. Remove those if you think it's too messy.

![Default Look](images/updated_tmux.png)

### Installation:
For clipboard support, please install **xclip** as well:

```bash
sudo apt install xclip
git clone https://github.com/hoodietramp/tmux_config.git
cd tmux_config
cp tmux.conf ~/.tmux.conf
cp vpnIP_VM.sh ~/Scripts/
chmod +x ~/Scripts/vpnIP_VM.sh
