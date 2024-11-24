softwareupdate --install-rosetta --agree-to-license
# install nix + run nix-darwin
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
nix run nix-darwin -- switch --flake ~/.config/nix-darwin#tn-macbook
