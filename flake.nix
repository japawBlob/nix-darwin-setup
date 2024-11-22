{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";	
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        [ 
	  pkgs.vim
	  pkgs.slack
  	  pkgs.coreutils
        ];
	environment.systemPath = [
		"/opt/homebrew/bin"
	];
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;
	users.users.jakub-jira = {
	name = "jakub-jira";
	home = "/Users/jakub-jira";
	};

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";


	homebrew = {
		enable = true;
		caskArgs.no_quarantine = true;
		global.brewfile = true;
		onActivation.cleanup = "zap";
		masApps = {};
		brews = [
			"mas"
		];
		casks = [
			"firefox"
			"maccy"
			"github"
		];
	};	
	fonts.packages = with pkgs; [
		(nerdfonts.override {
			fonts = [
				"JetBrainsMono"
				"CascadiaCode"
			];
		})
	];
      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
	system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;
	system.defaults.WindowManager.StandardHideDesktopIcons = false;
	system.defaults.dock.autohide = true;
	system.defaults.dock.autohide-delay = 0.0;
	system.defaults.dock.autohide-time-modifier = 0.3;
	system.defaults.NSGlobalDomain = {
		"com.apple.swipescrolldirection" = false;
		ApplePressAndHoldEnabled = false;
		InitialKeyRepeat = 14;
		KeyRepeat = 1;
	};
	system.activationScripts.extraActivation.text = ''
		softwareupdate --install-rosetta --agree-to-license
	'';
	security.pam.enableSudoTouchIdAuth = true;
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Jakubs-MacBook-Pro
    darwinConfigurations."Jakubs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration 
		home-manager.darwinModules.home-manager
		{
			home-manager.useGlobalPkgs = true;
			home-manager.useUserPackages = true;
			home-manager.backupFileExtension = "nix-backup";
			home-manager.users.jakub-jira = {config, pkgs, ...}:{
				home.username = "jakub-jira";
				home.homeDirectory = "/Users/jakub-jira";
				home.stateVersion = "24.05";
				programs.home-manager.enable = true;
				home.packages = [
					pkgs.bat
					pkgs.ripgrep
					pkgs.fzf
					pkgs.wget
					pkgs.vscode
					(pkgs.python3.withPackages (ppkgs: with ppkgs; [
						matplotlib 
						torch
					]))
				];
				
				programs.git = {
					enable = true;
					aliases = {
						csm = "commit -s -m";
						cm = "commit -m";
					};
					userEmail = "jakub.jira@turbonext.com";
					userName = "Jakub Jíra";
					
				};
				programs.poetry = {
					enable = true;
				};
				programs.firefox = {
					enable = true;					
					package = null;
					profiles.jakub = {
						isDefault = true;
						extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
							ublock-origin
							bitwarden
							vimium
							darkreader
							simple-tab-groups
						];
					};
				};
				programs.wezterm = {
					enable = true;
					enableZshIntegration = true;
					extraConfig = ''
						local wezterm = require 'wezterm'
						local config = wezterm.config_builder()
						config.font = wezterm.font("CaskaydiaCove Nerd Font")
						config.front_end = "WebGpu"
						config.color_scheme = 'Dark Pastel (Gogh)'
						config.window_decorations = "RESIZE"
						return config
					'';
				};
				programs.lazygit = {
					enable = true;
				};
				programs.zsh = {
					enable = true;
					shellAliases = {
						dwrs = "darwin-rebuild switch --flake ~/.config/nix-darwin";
						dwe = "vim ~/.config/nix-darwin/";
					}; 
				};
			};
		}	
		nix-homebrew.darwinModules.nix-homebrew
		{
			nix-homebrew = {
				enable = true;
				# Apple Silicon Only
				enableRosetta = true;
				# User owning the Homebrew prefix
				user = "jakub-jira";

				autoMigrate = true;
			};
		}
	];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Jakubs-MacBook-Pro".pkgs;
  };
}
