{
  self,
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  shared-system-packages = import ../shared/system-packages.nix { inherit pkgs; };
in
{
  imports = [
    ../shared
    ./home-manager.nix
  ];
  environment = {
    etc."pam.d/sudo_local".text = ''
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';
    shells = [
      pkgs.zsh
    ];
    systemPackages = shared-system-packages ++ [
      pkgs.appcleaner
      pkgs.pam-reattach
    ];
  };
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "ghostty"
    ];
    masApps = {
      "Goodnotes 6" = 1444383602;
      "KakaoTalk" = 869223134;
      "Messenger" = 1480068668;
      "SurfShark" = 1437809329;
      "Todoist" = 585829637;
      "WhatsApp" = 310633997;
    };
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
  };
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "@admin"
        "${user}"
      ];
    };
  };
  nix-homebrew = {
    inherit user;
    enable = true;
  };
  power.sleep = {
    computer = 20;
    display = 15;
  };
  services = {
    skhd.enable = true;
    yabai = {
      enable = true;
      enableScriptingAddition = true;
    };
  };
  system = {
    activationScripts.applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
      pkgs.lib.mkForce ''
        echo "setting up apps..." >&2
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r app_src; do
          app_name=$(basename -s ".app" "$app_src")
          echo "copying $app_name" >&2
          cp -R "$app_src" "/Applications"
          # icns_src="/icons/$app_name.icns"
          # if [ -f "$icns_src" ]; then
          #   icns_tgt=$(find "/Applications/$app_name.app/Contents/Resources" -name "*.icns")
          #   cp "$icns_src" "$icns_tgt"
          # fi
        done
        echo "resetting icons..." >&2
        rm -rf /Library/Caches/com.apple.iconservices.store 2>/dev/null
        find /private/var/folders/ \( -name com.apple.dock.iconcache -or -name com.apple.iconservices \) -exec rm -rf {} \; 2>/dev/null
        killall Finder
        killall Dock
      '';
    configurationRevision = self.rev or self.dirtyRev or null;
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        persistent-apps = [
          "/Applications/Google Chrome.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Calendar.app"
          "/Applications/Todoist.app"
          "/Applications/Spotify.app"
          "/Applications/Ghostty.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/VMware Fusion.app"
          "/Applications/Slack.app"
          "/Applications/KakaoTalk.app"
          "/Applications/WhatsApp.app"
          "/Applications/Messenger.app"
          "/System/Applications/System Settings.app"
        ];
        launchanim = false;
        mru-spaces = false;
        show-recents = false;
        wvous-br-corner = 1;
      };
      finder = {
        _FXSortFoldersFirst = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Home";
      };
      hitoolbox.AppleFnUsageType = "Change Input Source";
      loginwindow.GuestEnabled = false;
      menuExtraClock = {
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 1;
      };
      NSGlobalDomain = {
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
        AppleICUForce24HourTime = true;
        AppleMeasurementUnits = "Centimeters";
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        AppleSpacesSwitchOnActivate = false;
        AppleTemperatureUnit = "Celsius";
      };
      WindowManager = {
        EnableStandardClickToShowDesktop = false;
        EnableTiledWindowMargins = false;
        EnableTilingByEdgeDrag = false;
        EnableTilingOptionAccelerator = false;
        EnableTopTilingByEdgeDrag = false;
        StandardHideDesktopIcons = true;
        StandardHideWidgets = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    primaryUser = user;
    stateVersion = 6;
  };
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
  };
}
