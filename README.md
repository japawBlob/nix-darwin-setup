# This is my basic Nix-Darwin setup

This is my basic darwin-nix install. Feel free to use it - you just need to change my name "jakub-jira" and my devices name "Jakubs-MacBook-Pro" to match your device.

Instal nix using determinate systems installer:

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Clone the repository into ~/.config/nix-darwin

And the first time you run the config you need to run
```
nix run nix-darwin -- switch --flake ~/.config/nix-darwin
```

After that is succesfully done, you can use the regular 
```
darwin-rebuild switch --flake ~/.config/nix-darwin
```

# TODO:
 - add ```defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false              # For VS Code``` and Key Repeat and Delay Until Repeat
 - Karabiner modify keyboard
 - Install and setup Aerospace for window-management
 - Install alternative for spotligh
 - Install better top-bar
 - Setup wezterm
 - Install and setup oh-my-zsh
 - Install and setup vifm 
 - Add aliases for editing and rebuilding nix-darwin
 
