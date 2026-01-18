{
  self,
  config,
  pkgs,
  lib,
  user,
  targetDir,
  ...
}:
let
  sharedSystemPackages = import ../shared/system-packages.nix { inherit pkgs; };
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
    systemPackages = sharedSystemPackages ++ [
      pkgs.appcleaner
      pkgs.pam-reattach
    ];
  };
  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "orbstack"
    ];
    masApps = {
      "KakaoTalk" = 869223134;
      "SurfShark" = 1437809329;
      "WhatsApp" = 310633997;
    };
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
  };
  launchd.daemons.nix-gc = {
    serviceConfig = {
      Label = "com.system.nix-gc";
      ProgramArguments = [
        "${pkgs.nix}/bin/nix-collect-garbage"
        "--delete-older-than"
        "30d"
      ];
      StartCalendarInterval = {
        Hour = 2;
        Minute = 30;
      };
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
      RunAtLoad = false;
    };
  };
  networking = {
    knownNetworkServices = [
      "Wi-Fi"
    ];
    dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    hostName = "darwin";
  };
  nix.enable = false;
  nix-homebrew = {
    inherit user;
    enable = true;
  };
  power.sleep = {
    computer = 20;
    display = 15;
  };
  programs = {
    fish.enable = true;
    zsh.enable = true;
  };
  services = {
    skhd.enable = true;
    yabai = {
      enable = true;
      enableScriptingAddition = true;
    };
  };
  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        persistent-apps = [
          "/Applications/Helium.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Calendar.app"
          "/Applications/Nix Apps/Spotify.app"
          "/Applications/Ghostty.app"
          "${config.users.users.${user}.home}/Applications/Home Manager Apps/Visual Studio Code.app"
          "/Applications/Nix Apps/Slack.app"
          "/Applications/KakaoTalk.app"
          "/Applications/WhatsApp.app"
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
