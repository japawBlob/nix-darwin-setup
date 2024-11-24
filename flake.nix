{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";	
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    determinate.inputs.nixpkgs.follows = "nixpkgs";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, firefox-addons, determinate }:
  let
    configuration = { pkgs, config,... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        [ 
	  pkgs.vim
	  pkgs.mkalias
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
		global.autoUpdate = false;
		onActivation.upgrade = true;
		onActivation.autoUpdate = true;
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
	system.defaults.WindowManager.StandardHideDesktopIcons = true;
	system.defaults.dock.autohide = true;
	system.defaults.dock.autohide-delay = 0.0;
	system.defaults.dock.autohide-time-modifier = 0.3;
	system.defaults.NSGlobalDomain = {
		ApplePressAndHoldEnabled = false;
		InitialKeyRepeat = 14;
		KeyRepeat = 1;
		"com.apple.mouse.tapBehavior" = 1;
		"com.apple.keyboard.fnState" = true;
		"com.apple.swipescrolldirection" = false;
		"com.apple.trackpad.scaling" = 1.0;
	};
	security.pam.enableSudoTouchIdAuth = true;
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
	system.activationScripts.applications.text = let
        	env = pkgs.buildEnv {
          		name = "system-applications";
          		paths = config.environment.systemPackages;
          		pathsToLink = "/Applications";
        	};
      	in
        	pkgs.lib.mkForce ''
          		# Set up applications.
          		echo "setting up /Applications..." >&2
          		rm -rf /Applications/Nix\ Apps
          		mkdir -p /Applications/Nix\ Apps
          		find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          		while read -r src; do
            		app_name=$(basename "$src")
            		echo "copying $src" >&2
            		${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          		done
        	'';
    	};
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#tn-macbook
    darwinConfigurations."tn-macbook" = nix-darwin.lib.darwinSystem {
	system = "aarch64-darwin";
	modules = [ 
		configuration 
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
					pkgs.neovim
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
						dwrs = "darwin-rebuild switch --flake ~/.config/nix-darwin#tn-macbook";
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
		determinate.darwinModules.default
	];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."tn-macbook".pkgs;
  };
}
