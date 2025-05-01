#!/bin/bash

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
  echo "Zsh is not installed. Installing Zsh..."
  sudo apt update && sudo apt install zsh -y
else
  echo "Zsh is already installed."
fi

# Install Oh My Zsh if it's not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is not installed. Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed."
fi

# Define the custom plugin directory for oh-my-zsh
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Function to check if a plugin is already installed
check_and_clone_plugin() {
  PLUGIN_NAME=$1
  PLUGIN_REPO=$2

  if [ ! -d "$ZSH_CUSTOM/plugins/$PLUGIN_NAME" ]; then
    echo "Installing $PLUGIN_NAME..."
    git clone $PLUGIN_REPO $ZSH_CUSTOM/plugins/$PLUGIN_NAME
  else
    echo "$PLUGIN_NAME is already installed."
  fi
}

# Install zsh-autosuggestions
check_and_clone_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"

# Install zsh-syntax-highlighting
check_and_clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# Add plugins to .zshrc if not already added
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  echo "Enabling zsh-autosuggestions plugin in .zshrc..."
  sed -i '/^plugins=(/ s/)/ zsh-autosuggestions)/' ~/.zshrc
fi

if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
  echo "Enabling zsh-syntax-highlighting plugin in .zshrc..."
  sed -i '/^plugins=(/ s/)/ zsh-syntax-highlighting)/' ~/.zshrc
fi

# Optionally, set the highlight color for autosuggestions
if ! grep -q "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" ~/.zshrc; then
  echo "Setting autosuggestion highlight color..."
  echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#808080'" >> ~/.zshrc
fi

# Source .zshrc to apply changes
echo "Sourcing ~/.zshrc to apply changes..."
source ~/.zshrc

# Change the default shell to Zsh
echo "Changing default shell to Zsh..."
chsh -s $(which zsh)

echo "Installation and configuration complete! Please restart your terminal or log out and log back in for the changes to take effect."
