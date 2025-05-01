## Zsh Installation and Plugin Setup Script

This script automates the installation of Zsh, Oh My Zsh, and some useful plugins. Here’s what the script does:

1. **Installs Zsh**: If Zsh is not already installed, it will install it.
2. **Installs Oh My Zsh**: If Oh My Zsh is not installed, it downloads and installs it.
3. **Installs Plugins**: It installs the `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins.
4. **Updates .zshrc**: It ensures that the plugins are added to your `.zshrc` file and sets the autosuggestion highlight color.
5. **Changes the Default Shell to Zsh**: The script automatically changes your default shell to Zsh using:
   ```bash
   chsh -s $(which zsh)
6. **Applies Changes: It sources the .zshrc file so the changes take effect immediately.**

# Steps to Use the Script

Make the script executable:
```bash
chmod +x install-zsh-and-plugins.sh
```
Run the script:
```bash
./install-zsh-and-plugins.sh
```
After running the script, your default shell will be Zsh, with Oh My Zsh, zsh-autosuggestions, and zsh-syntax-highlighting installed and configured.
