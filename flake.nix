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

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, firefox-addons}:
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
	  pkgs.vscode
	  pkgs.wezterm
        ];
	environment.systemPath = [
		"/opt/homebrew/bin"
	];
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;
	users.users.japaw = {
	name = "japaw";
	home = "/Users/japaw";
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
		taps = [
			"hashicorp/tap"
		];
		brews = [
			"mas"
			"terraform"
			"node"
			"azure-cli"
			"docker"
			"colima"
			"lima"
		];
		casks = [
			"firefox"
			"maccy"
			"github"
			"simplenote"
			"prusaslicer"
			"whatsapp"
			"proton-drive"
			"proton-mail"
			"karabiner-elements"
			"hammerspoon"
			"onlyoffice"
			"libreoffice"
			"vlc"
		];
	};	
	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
		nerd-fonts.caskaydia-cove
	];
      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
	system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;
	system.defaults.WindowManager.StandardHideDesktopIcons = true;
	system.defaults.trackpad.FirstClickThreshold = 0;
	system.defaults.trackpad.ActuationStrength = 0;
	system.defaults.dock.autohide = true;
	system.defaults.dock.autohide-delay = 0.0;
	system.defaults.dock.autohide-time-modifier = 0.3;
	system.defaults.dock.wvous-bl-corner = 1;
	system.defaults.dock.wvous-br-corner = 1;
	system.defaults.dock.wvous-tl-corner = 1;
	system.defaults.dock.wvous-tr-corner = 1;
	system.defaults.dock.orientation = "left";
	system.defaults.dock.show-recents = false;
	system.defaults.dock.tilesize = 64;
	system.defaults.dock.persistent-apps = [
		"/System/Applications/Launchpad.app"
		"/System/Applications/System Settings.app"
		"${pkgs.wezterm}/Applications/WezTerm.app"
		"/Applications/Firefox.app"
		"/Applications/Messenger.app"
		"${pkgs.vscode}/Applications/Visual Studio Code.app"
		"/Applications/Microsoft Teams.app"	
		"${pkgs.slack}/Applications/Slack.app"
		"/Applications/Simplenote.app"
	];
	system.defaults.finder.CreateDesktop = false;
	system.defaults.finder.AppleShowAllExtensions = true;
	system.defaults.finder.AppleShowAllFiles = true;
	system.defaults.finder.ShowPathbar = true;
	system.defaults.finder.ShowStatusBar = true;
	system.defaults.finder._FXShowPosixPathInTitle = true;
	system.defaults.finder._FXSortFoldersFirst = true;
	system.defaults.loginwindow.GuestEnabled = false;
	system.defaults.NSGlobalDomain = {
		ApplePressAndHoldEnabled = false;
		InitialKeyRepeat = 14;
		KeyRepeat = 1;
		AppleTemperatureUnit = "Celsius";
		NSWindowShouldDragOnGesture = true;
		"com.apple.mouse.tapBehavior" = 1;
		"com.apple.keyboard.fnState" = true;
		"com.apple.swipescrolldirection" = false;
		"com.apple.trackpad.scaling" = 2.0;
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
			home-manager.users.japaw = {config, pkgs, ...}:{
				home.username = "japaw";
				home.homeDirectory = "/Users/japaw";
				home.stateVersion = "24.05";
				programs.home-manager.enable = true;
				home.sessionPath = [
					"$PYENV_ROOT/bin"
				];
				home.sessionVariables = {
					EDITOR="nvim";
					PYENV_ROOT="$HOME/.pyenv";
				};
				home.packages = [
					pkgs.bat
					pkgs.ripgrep
					pkgs.fzf
					pkgs.wget
					pkgs.neovim
					pkgs.btop
					pkgs.pyenv
					pkgs.eza
					pkgs.vifm
					(pkgs.python3.withPackages (ppkgs: with ppkgs; [
						matplotlib 
						torch
						pytest
					]))
				];
				
				programs.git = {
					enable = true;
					aliases = {
						csm = "commit -s -m";
						cm = "commit -m";
					};
					userEmail = "jakub.jira@turbonext.ai";
					userName = "Jakub Jíra";
					
				};
				programs.ssh = {
					enable = true;
					addKeysToAgent = "yes";
				};
				programs.poetry = {
					enable = true;
				};
				programs.firefox = {
					enable = true;					
					package = null;
					profiles.japaw = {
						isDefault = true;
						extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
							ublock-origin
							bitwarden
							vimium
							darkreader
							simple-tab-groups
							youtube-nonstop
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
						config.initial_cols = 160
						config.initial_rows = 48
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
				programs.zoxide = {
					enable = true;
					enableZshIntegration = true;
				};
				programs.starship = {
					enable = true;
					enableZshIntegration = true;
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
				user = "japaw";

				autoMigrate = true;
			};
		}
	];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."tn-macbook".pkgs;
  };
}
