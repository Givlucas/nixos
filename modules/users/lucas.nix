# Lucas user configuration
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userProfiles.lucas;
  userCfg = config.userProfiles;
in
{

  options.userProfiles.lucas = {
    enable = lib.mkEnableOption "lucas user account";
  };

  config = lib.mkIf cfg.enable {
    # System user
    users.users.lucas = {
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" "plugdev" "docker" "libvirtd" ];
      useDefaultShell = true;
    };

    # Home-manager configuration
    home-manager.users.lucas = lib.mkIf userCfg.enableHomeManager ({ config, pkgs, ... }: {
      imports = [ inputs.impermanence.homeManagerModules.impermanence ];

      home.username = "lucas";
      home.homeDirectory = "/home/lucas";

      home.file.".config/nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
        }
      '';

      # Symlink media directories from .core to home
      home.file."Pictures".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.core/Pictures";
      home.file."Videos".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.core/Videos";
      home.file."Music".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.core/Music";

      # Claude Code status line script
      home.file.".claude/statusline.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # Parse JSON input from Claude Code
          input=$(cat)
          model=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.model.display_name // "Claude"')
          cwd=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.cwd // "."')
          cost=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.cost.total_cost_usd // 0')

          # Context window info
          input_tokens=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.total_input_tokens // 0')
          output_tokens=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.total_output_tokens // 0')
          context_size=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.context_window_size // 200000')

          # Calculate total tokens and format as K
          total_tokens=$((input_tokens + output_tokens))
          tokens_k=$(echo "scale=1; $total_tokens / 1000" | ${pkgs.bc}/bin/bc)
          context_k=$(echo "scale=0; $context_size / 1000" | ${pkgs.bc}/bin/bc)

          # Format cost
          cost_fmt=$(printf "%.4f" "$cost")

          # Get git status if in a git repo
          git_info=""
          if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
            branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

            # Check for uncommitted changes
            if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
              dirty="*"
            else
              dirty=""
            fi

            # Check for untracked files
            if [ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]; then
              untracked="+"
            else
              untracked=""
            fi

            git_info="\033[33m$branch$dirty$untracked\033[0m "
          fi

          # Output status line with colors
          echo -e "$git_info\033[36m$model\033[0m \033[35m''${tokens_k}K/''${context_k}K\033[0m \033[32m\$$cost_fmt\033[0m"
        '';
      };

      # Claude Code settings
      home.file.".claude/settings.json".text = builtins.toJSON {
        statusLine = {
          type = "command";
          command = "~/.claude/statusline.sh";
        };
      };

      home.packages = with pkgs; [
        # Development
        claude-code
        android-studio
        android-tools
        arduino
        kicad
        kotlin-language-server
        nil
        nixos-anywhere

        # Design & Media
        inkscape
        gimp
        freecad
        ffmpeg
        dvdauthor

        # Productivity
        obsidian
        calibre
        libreoffice
        xournalpp
        anki-bin

        # Communication & Web
        google-chrome
        discord
        tor-browser
        deluge

        # Gaming
        prismlauncher
        gamescope
        spotify

        # Radio & Hardware
        sdrpp
        betaflight-configurator
        splat

        # Shell & Theming
        oh-my-zsh
        adw-gtk3
        raleway

        # GNOME utilities
        gnome-tweaks

        # GNOME Extensions
        gnomeExtensions.compiz-alike-magic-lamp-effect
        gnomeExtensions.compiz-windows-effect
        gnomeExtensions.tiling-shell
        gnomeExtensions.dash-to-dock
        gnomeExtensions.blur-my-shell
        gnomeExtensions.hide-top-bar
        gnomeExtensions.rounded-window-corners-reborn
        gnomeExtensions.just-perfection
        gnomeExtensions.light-style
      ];

      programs.helix = {
        enable = true;
        settings = {
          theme = "base16_default";
          editor = {
            rulers = [ 80 120 ];
            bufferline = "multiple";
            soft-wrap.enable = true;
          };
        };
      };

      programs.firefox = {
        enable = true;
        profiles.lucas = {
          extensions.packages = with inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons; [
            raindropio
          ];
          settings = {
            # Enable vertical tabs
            "sidebar.verticalTabs" = true;
            "sidebar.revamp" = true;

            # Hide horizontal tab bar
            "browser.tabs.tabmanager.enabled" = true;

            # Additional settings for better vertical tabs experience
            "browser.tabs.firefox-view" = false;

            # Remove ads and sponsored content from home page
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          };

          search = {
            default = "Kagi";
            force = true;
            engines = {
              "Kagi" = {
                urls = [{
                  template = "https://kagi.com/search?q={searchTerms}";
                }];
                icon = "https://kagi.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000;
                definedAliases = [ "@k" ];
              };
            };
          };
        };
      };

      # GNOME dconf settings
      dconf = {
        enable = true;

        settings = {
          # Enable GNOME Shell extensions
          "org/gnome/shell" = {
            disable-user-extensions = false;

            enabled-extensions = with pkgs.gnomeExtensions; [
              compiz-alike-magic-lamp-effect.extensionUuid
              compiz-windows-effect.extensionUuid
              tiling-shell.extensionUuid
              dash-to-dock.extensionUuid
              blur-my-shell.extensionUuid
              rounded-window-corners-reborn.extensionUuid
              just-perfection.extensionUuid
              light-style.extensionUuid
            ];
          };

          # Dash to Dock configuration
          "org/gnome/shell/extensions/dash-to-dock" = {
            dock-position = "BOTTOM";
            dock-fixed = false;
            autohide = true;
            intellihide = false;
            dash-max-icon-size = 48;
            show-trash = false;
            show-mounts = false;
            transparency-mode = "DYNAMIC";
            background-opacity = 0.8;
            click-action = "MINIMIZE";
            scroll-action = "switch-workspace";
          };

          # Blur My Shell configuration
          "org/gnome/shell/extensions/blur-my-shell" = {
            brightness = 0.6;
            sigma = 30;
          };

          "org/gnome/shell/extensions/blur-my-shell/panel" = {
            blur = true;
            customize = true;
            sigma = 30;
            brightness = 0.6;
            override-background = true;
            force-light-text = true;
          };

          "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
            blur = true;
            customize = true;
            static-blur = true;
            override-background = true;
          };
        };
      };

      home.stateVersion = "25.05";
    });

    # Persist lucas home in impermanence
    environment.persistence = lib.mkIf (config.impermanence.enable or false) {
      "${userCfg.persistDir}".users.lucas = {
        directories = [
          "Documents"
          "Downloads"
          ".core"
          ".config"
          ".local"
          ".ssh"
          ".gnupg"
        ];
      };
    };
  };
}
