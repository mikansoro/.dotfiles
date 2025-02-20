{ config, pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # https://github.com/DeterminateSystems/nix-installer/issues/234
  # Determinite Systems Installer doesn't add a nix channel, so nix-shell doesn't work
  # adding extra-nix-path fixes it
  nix.extraOptions = ''
    auto-optimise-store = false
    experimental-features = nix-command flakes
    extra-nix-path = nixpkgs=flake:nixpkgs
  '';

  #fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    ibm-plex
    source-code-pro
    source-sans-pro
    source-serif-pro
    noto-fonts-cjk-sans
    source-han-sans-japanese
    source-han-sans-korean
    source-han-sans-simplified-chinese
    source-han-serif-japanese
    source-han-serif-korean
    source-han-serif-simplified-chinese
    source-han-code-jp
    emacsPackages.nerd-icons
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    # NOTE: Temporarily disable homebrew integration until i can remove the old binaries
    enable = false;
    brews = [
      {
        name = "superbrothers/opener/opener";
        start_service = true;
        restart_service = true;
      }
      "hyperkit"
      # cloudquery
    ];
    casks = [
      "spotify"
      "iterm2"
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina



  services.yabai = {
    enable = false;
    enableScriptingAddition = true;
    config = {
      layout = "bsp";
      window_placement = "second_child";
      window_shadow = "on";

      botton_padding = 8;
      top_padding = 8;
      left_padding = 8;
      right_padding = 8;
      window_gap = 10;

      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_follows_focus = "off";
      # focus_follows_mouse = "autoraise";

    };
    extraConfig = ''
      yabai -m config external_bar all:0:${toString config.services.spacebar.config.height}
      yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
      yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
      yabai -m rule --add app="^(Calculator|Software Update|Dictionary|System Preferences|System Settings|Archive Utility|Activity Monitor)$" manage=off

      yabai -m space 1 --label persistence
      yabai -m space 2 --label emacs
      yabai -m space 3 --label active-work
      yabai -m space 4 --label slack
      yabai -m space 9 --label music

      yabai -m rule --add app="Notion" space=persistence
      yabai -m rule --add app="Google Chrome" space=persistence
      yabai -m rule --add app="Emacs" space=emacs
      yabai -m rule --add app="Slack" space=slack
      yabai -m rule --add app="Spotify" space=music
    '';
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      alt + shift - e : emacsclient --eval "(emacs-everywhere)"
    '';
    # skhdConfig = ''
    #   alt - h : yabai -m window --focus west
    #   alt - j : yabai -m window --focus north
    #   alt - k : yabai -m window --focus south
    #   alt - l : yabai -m window --focus east

    #   alt + shift - h : yabai -m space prev
    #   alt + shift - l : yabai -m space next
    #   ctrl + alt - f : yabai -m window --space next; yabai -m space --focus next
    #   ctrl + alt - s : yabai -m window --space prev; yabai -m space --focus prev

    #   alt - e : yabai -m display --focus next
    #   alt - d : yabai -m display --focus prev
    #   shift + alt - e : yabai -m window --display next; yabai -m display --focus next
    #   shift + alt - d : yabai -m window --display prev; yabai -m display --focus prev
    # '';
  };

  services.spacebar = {
    enable = false;
    config = {
      position                   = "top";
      display                    = "main";
      height                     = 26;
      title                      = "on";
      spaces                     = "on";
      clock                      = "on";
      power                      = "on";
      padding_left               = 20;
      padding_right              = 20;
      spacing_left               = 25;
      spacing_right              = 15;
      text_font                  = ''"Source Sans Pro:12.0"'';
      icon_font                  = ''"Font Awesome 5 Free:Solid:12.0"'';
      background_color           = "0xff202020";
      foreground_color           = "0xffa8a8a8";
      power_icon_color           = "0xffcd950c";
      battery_icon_color         = "0xffd75f5f";
      dnd_icon_color             = "0xffa8a8a8";
      clock_icon_color           = "0xffa8a8a8";
      power_icon_strip           = " ";
      space_icon                 = "•";
      space_icon_strip           = "1 2 3 4 5 6 7 8 9 10";
      spaces_for_all_displays    = "on";
      display_separator          = "on";
      display_separator_icon     = "";
      space_icon_color           = "0xff458588";
      space_icon_color_secondary = "0xff78c4d4";
      space_icon_color_tertiary  = "0xfffff9b0";
      clock_icon                 = "";
      dnd_icon                   = "";
      clock_format               = ''"%d/%m/%y %R"'';
      right_shell                = "on";
      right_shell_icon           = "";
      right_shell_command        = "whoami";
    };
  };

  # workaround for a single user system: https://github.com/LnL7/nix-darwin/pull/252#issuecomment-731083818
  # emacs doesn't handle $USER or $HOME expansion in PATH, so even when the path is set via launchd packages
  # installed via homeassistant aren't found. Have to replace the variables to be static before the PATH is
  # set, otherwise emacs won't load additional packages from path (ie ripgrep, language servers)
  launchd.user.envVariables.PATH = (lib.replaceStrings ["$HOME" "$USER"]
    [config.users.users."michael.rowland".home config.users.users."michael.rowland".name]
    config.environment.systemPath);

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
