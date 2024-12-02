# This is my basic Nix-Darwin setup

This is my basic darwin-nix install. Feel free to use it - you just need to change my user name "japaw" to yours and some personal credentials like name and email.

## What is the Nix?

The nix is package manager originally aimed ad Linux, that provides a way to create a declarative and deterministic developement environments. There is a little mess in the nix world and the learning curve can be quite steep. If you are interested I would suggest starting to manage your cli tools with nix and get the look and feel of it and maybe check some guides like [Zero to Nix](https://zero-to-nix.com/) or [nice youtube video by Dreams of Autonomy](https://www.youtube.com/watch?v=Z8BL8mdzWHI)

## How to install?

Instal nix using determinate systems installer:

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Clone the repository into ~/.config/nix-darwin

And the first time you run the config you need to run
```
nix run nix-darwin -- switch --flake ~/.config/nix-darwin#tn-macbook
```

After that is succesfully done, you can use the regular 
```
darwin-rebuild switch --flake ~/.config/nix-darwin#tn-macbook
```

## TODO:
 - Karabiner modify keyboard
 - Install and setup Aerospace for window-management
 - Install alternative for spotligh
 - Install better top-bar
 - Install and setup oh-my-zsh
 - Install and setup vifm 

## Need to do manually:
 - Firefox needs to start first, before applying configuration from home-manager
 - Firefox does not transfer bookmarks - maybe use standalone firefox accnout for once? - can be done by tranfering flavicons.sqlite and places.sqlite to ~/Library/Application Support/Firefox/profiles/<profile name>
 - VSCode also needs some setup
 - Multi-monitor setup make the external monitor primary one
 - Set background to plane black + accents to gray
 - Generate SSH key + transfer key from old pc
 - Install KDEConnect, Teams, Messenger
 - Set UI scale both on laptop and external monitor
 - Set Teams, Slack, KDEConnect to be startup apps
 - Vimium setup
 - Set tiled windows to not have margins
 - Give wezterm full disk access in Privacy & Security -> Full Disk Access
 - Allow kdeconnect to be run as app from an unknown developer
