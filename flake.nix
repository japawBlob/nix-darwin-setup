{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";	
    hashicorp-tap = {
      url = "github:hashicorp/homebrew-tap";
      flake = false;
    };
    nikitabobko-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    felixkratz-tap = {
      url = "github:felixkratz/homebrew-formulae";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    catppuccin.url = "github:catppuccin/nix";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    textfox.url = "github:adriankarlen/textfox";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, firefox-addons, catppuccin, textfox, homebrew-core, homebrew-cask, homebrew-bundle, hashicorp-tap, nikitabobko-tap, felixkratz-tap}:
  let
    configuration = { pkgs, config,... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        [ 
	  pkgs.vim
	  pkgs.mkalias
  	  pkgs.coreutils
	  pkgs.vscode
        ];
	environment.systemPath = [
		"/opt/homebrew/bin"
	];
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
		global.autoUpdate = true;
		onActivation.upgrade = true;
		onActivation.autoUpdate = true;
		onActivation.cleanup = "uninstall";
		masApps = {};
		taps = [
			"hashicorp/tap"
			"nikitabobko/tap"
			"FelixKratz/formulae"
			"homebrew/homebrew-core"
			"homebrew/homebrew-cask"
			"homebrew/homebrew-bundle"
		];
		brews = [
			"mas"
			"terraform"
			"node"
			"azure-cli"
			"docker"
			"colima"
			"lima"
			"borders"
			"sketchybar"
			"tldr"
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
			#"onlyoffice"
			"libreoffice"
			"vlc"
			"obs"
			"kdenlive"
			"gimp"
			"balenaetcher"
			"chromium"
			"sol"
			"discord"
			"aerospace"
			"wezterm"
			"slack"
			"raspberry-pi-imager"
			"zed"
			"floorp"
		];
	};	
	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
		nerd-fonts.caskaydia-cove
		nerd-fonts.hack
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
	system.defaults.dock.tilesize = 50;
	system.defaults.dock.mru-spaces = false;
	system.defaults.dock.persistent-apps = [
 		"/System/Applications/Launchpad.app"
 		"/System/Applications/System Settings.app"
 		"/Applications/WezTerm.app"
 		"/Applications/Firefox.app"
 		"/Applications/Messenger.app"
 		"${pkgs.vscode}/Applications/Visual Studio Code.app"
 		"/Applications/Microsoft Teams.app"	
 		"/Applications/Slack.app"
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
	system.defaults.spaces.spans-displays = true;
	system.defaults.NSGlobalDomain = {
		ApplePressAndHoldEnabled = false;
		InitialKeyRepeat = 14;
		KeyRepeat = 1;
		AppleTemperatureUnit = "Celsius";
		NSWindowShouldDragOnGesture = true;
		_HIHideMenuBar = false;
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
				imports = [
					catppuccin.homeManagerModules.catppuccin
					textfox.homeManagerModules.default
				];
				catppuccin = {
					enable = true;
					flavor = "mocha";
				};
				textfox = {
					enable = false;
					profile = "japaw";
					config = {
						tabs = {
						  vertical.margin = "0.5rem";
						  horizontal.enable = true;
						};
						displayWindowControls = false;
						displayNavButtons = false;
						displayUrlbarIcons = false;
						displaySidebarTools = false;
						displayTitles = false;
						newtabLogo = "   __            __  ____          \A   / /____  _  __/ /_/ __/___  _  __\A  / __/ _ \\| |/_/ __/ /_/ __ \\| |/_/\A / /_/  __/>  </ /_/ __/ /_/ />  <  \A \\__/\\___/_/|_|\\__/_/  \\____/_/|_|  ";
						font = { 
						  family = "Fira Code";
						  size = "15px";
						  accent = "#654321";
						};
					      };
				};
				home.username = "japaw";
				home.homeDirectory = "/Users/japaw";
				home.stateVersion = "24.05";
				programs.home-manager.enable = true;
				home.sessionPath = [
					"$PYENV_ROOT/bin"
					"$HOME/go/bin"
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
					pkgs.btop
					pkgs.pyenv
					pkgs.eza
					pkgs.vifm
					pkgs.go
					pkgs.lsd
					pkgs.pandoc
					(pkgs.python3.withPackages (ppkgs: with ppkgs; [
						matplotlib 
						torch
						pytest
						mkdocs
					]))
					pkgs.nnn
					pkgs.gh
					pkgs.imagemagick
				];
				home.file = {
					".config/wezterm/wezterm.lua" = {
						enable = true;
						text = ''
local wezterm = require 'wezterm'
local config = wezterm.config_builder()
config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.front_end = "WebGpu"
config.window_close_confirmation = 'NeverPrompt'
config.color_scheme = 'Catppuccin Mocha' 
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 160
config.initial_rows = 48
config.font_size = 18
config.audible_bell = "Disabled"
config.use_fancy_tab_bar = false
config.scrollback_lines = 12000
-- build your config according to
-- https://wezfurlong.org/wezterm/config/lua/wezterm/config_builder.html

-- the plugin is currently made for Catppuccin only

-- then finally apply the plugin
-- these are currently the defaults:
wezterm.plugin.require("https://github.com/japawBlob/wezterm-bar").apply_to_config(config, {
  position = "top",
  max_width = 16,
  dividers = false, -- or "slant_right", "slant_left", "arrows", "rounded", false
  indicator = {
    leader = {
      enabled = false,
      off = " ",
      on = " ",
    },
    mode = {
      enabled = false,
      names = {
        resize_mode = "RESIZE",
        copy_mode = "VISUAL",
        search_mode = "SEARCH",
      },
    },
  },
  tabs = {
    numerals = "arabic", -- or "roman"
    pane_count = "superscript", -- or "subscript", false
    brackets = {
      active = { "", ":" },
      inactive = { "", ":" },
    },
    colours = {
    	"#89b4fa",
    },
  },
  clock = { -- note that this overrides the whole set_right_status
    enabled = true,
    format = "%H:%M", -- use https://wezfurlong.org/wezterm/config/lua/wezterm.time/Time/format.html
  },
})
config.window_frame = {
	active_titlebar_bg = '#89b4fa'
}
return config
						'';
					};
				};
				
				programs.git = {
					enable = true;
					aliases = {
						csm = "commit -s -m";
						cm = "commit -m";
					};
					userEmail = "jakub.jira@turbonext.ai";
					userName = "Jakub Jíra";
					extraConfig = {init.defaultBranch = "main";};
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
				programs.lazygit = {
					enable = true;
				};
				programs.zsh = {
					enable = true;
					shellAliases = {
						dwrs = "darwin-rebuild switch --flake ~/.config/nix-darwin#tn-macbook";
						dwe = "nvim ~/.config/nix-darwin/";
						ls = "eza --icons=always -x --sort type";
						la = "eza --icons=always -x --sort type -la";
						lst = "eza --icons=always -x --sort type --tree";
						cd = "z";
						mvim = "nvim";
					}; 
				};
				programs.zoxide = {
					enable = true;
					enableZshIntegration = true;
				};
				programs.starship = {
					enable = true;
					enableZshIntegration = true;
					settings = {
						add_newline = false;
						directory = {
							truncation_length = 8;	
							truncate_to_repo = true;
							truncation_symbol = "../";
							style = "bold blue";
						};
					};
				};
				programs.neovim = {
					enable = true;
					viAlias = true;
					vimAlias = true;
					vimdiffAlias = true;
					extraConfig = ''
						set termguicolors
						set number
						set relativenumber
						colorscheme catppuccin-mocha
					'';
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
				taps = {
					"homebrew/homebrew-core" = homebrew-core;
				      	"homebrew/homebrew-cask" = homebrew-cask;
				      	"homebrew/homebrew-bundle" = homebrew-bundle;
					"hashicorp/tap" = hashicorp-tap;
					"nikitabobko/tap" = nikitabobko-tap;
					"FelixKratz/formulae" = felixkratz-tap;
				};
				mutableTaps = true;
			};
		}
	];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."tn-macbook".pkgs;
  };
}
