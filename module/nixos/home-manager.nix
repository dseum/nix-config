{
  user,
  targetDir,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = {
      inherit targetDir;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} =
      {
        lib,
        pkgs,
        ...
      }:
      let
        emptyKeybinding = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
        popShellWithoutIndicator = pkgs.gnomeExtensions.pop-shell.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            substituteInPlace "$out/share/gnome-shell/extensions/pop-shell@system76.com/extension.js" \
              --replace-fail "panel.addToStatusArea('pop-shell', indicator.button);" ""
          '';
        });
        workspaceKeys = {
          "Above_Tab" = 1;
          "1" = 2;
          "2" = 3;
          "3" = 4;
          "4" = 5;
          "5" = 6;
          "q" = 7;
          "w" = 8;
          "e" = 9;
          "r" = 10;
        };
        workspaceKeybindings = lib.concatMapAttrs (
          key: workspace:
          let
            number = toString workspace;
          in
          {
            "move-to-workspace-${number}" = [ "<Super><Control>${key}" ];
            "switch-to-workspace-${number}" = [ "<Super>${key}" ];
          }
        ) workspaceKeys;
        shellApplicationKeybindings = lib.genAttrs (lib.concatMap (number: [
          "open-new-window-application-${toString number}"
          "switch-to-application-${toString number}"
        ]) (lib.range 1 9)) (_: emptyKeybinding);
        customKeybindingPath = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";
      in
      {
        imports = [
          ../shared/home-manager.nix
        ];
        home = {
          homeDirectory = "/home/${user}";
          packages = import ./packages.nix { inherit pkgs; };
          username = user;
        };
        dconf.settings = {
          "org/gnome/desktop/background" = {
            picture-options = "zoom";
            picture-uri = "file:///home/${user}/Pictures/wallpaper.jpg";
            picture-uri-dark = "file:///home/${user}/Pictures/wallpaper.jpg";
          };
          "org/gnome/desktop/datetime".automatic-timezone = true;
          "org/gnome/desktop/interface".enable-animations = false;
          "org/gnome/desktop/peripherals/touchpad" = {
            disable-while-typing = true;
            natural-scroll = true;
            tap-to-click = false;
          };
          "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 (15 * 60);
          "org/gnome/desktop/wm/keybindings" = workspaceKeybindings // {
            close = [ "<Alt>F4" ];
            minimize = emptyKeybinding;
            move-to-workspace-left = [ "<Super><Control>u" ];
            move-to-workspace-right = [ "<Super><Control>i" ];
            switch-applications = emptyKeybinding;
            switch-applications-backward = emptyKeybinding;
            switch-group = emptyKeybinding;
            switch-group-backward = emptyKeybinding;
            switch-to-workspace-left = [ "<Super>u" ];
            switch-to-workspace-right = [ "<Super>i" ];
            switch-windows = [ "<Alt>Tab" ];
            switch-windows-backward = [ "<Shift><Alt>Tab" ];
          };
          "org/gnome/desktop/wm/preferences".num-workspaces = 10;
          "org/gnome/mutter" = {
            dynamic-workspaces = false;
            edge-tiling = false;
            workspaces-only-on-primary = true;
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "${customKeybindingPath}/chrome-1/"
              "${customKeybindingPath}/chrome-2/"
              "${customKeybindingPath}/chrome-3/"
              "${customKeybindingPath}/chrome-4/"
              "${customKeybindingPath}/1password-quick-access/"
              "${customKeybindingPath}/terminal/"
            ];
            screensaver = [ "<Super><Alt>l" ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-1" = {
            binding = "<Shift><Super>1";
            command = "google-chrome-stable --profile-directory=Default --new-window";
            name = "Chrome Profile 1";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-2" = {
            binding = "<Shift><Super>2";
            command = "google-chrome-stable --profile-directory='Profile 1' --new-window";
            name = "Chrome Profile 2";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-3" = {
            binding = "<Shift><Super>3";
            command = "google-chrome-stable --profile-directory='Profile 2' --new-window";
            name = "Chrome Profile 3";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-4" = {
            binding = "<Shift><Super>4";
            command = "google-chrome-stable --profile-directory='Profile 3' --new-window";
            name = "Chrome Profile 4";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password-quick-access" = {
            binding = "<Control><Shift>space";
            command = "1password --quick-access";
            name = "Show Quick Access";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
            binding = "<Shift><Super>e";
            command = "ghostty";
            name = "Ghostty";
          };
          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-timeout = lib.hm.gvariant.mkInt32 (60 * 60);
            sleep-inactive-ac-type = "suspend";
            sleep-inactive-battery-timeout = lib.hm.gvariant.mkInt32 (30 * 60);
            sleep-inactive-battery-type = "suspend";
          };
          "org/gnome/shell/keybindings" = shellApplicationKeybindings // {
            focus-active-notification = emptyKeybinding;
            toggle-message-tray = [ "<Super>m" ];
          };
          "org/gnome/shell/extensions/pop-shell" = {
            activate-launcher = emptyKeybinding;
            active-hint = false;
            focus-down = [ "<Super>j" ];
            focus-left = [ "<Super>h" ];
            focus-right = [ "<Super>l" ];
            focus-up = [ "<Super>k" ];
            gap-inner = lib.hm.gvariant.mkUint32 8;
            gap-outer = lib.hm.gvariant.mkUint32 8;
            mouse-cursor-follows-active-window = true;
            pop-monitor-down = [ "<Super><Control><Shift>j" ];
            pop-monitor-left = [ "<Super><Control><Shift>h" ];
            pop-monitor-right = [ "<Super><Control><Shift>l" ];
            pop-monitor-up = [ "<Super><Control><Shift>k" ];
            pop-workspace-down = emptyKeybinding;
            pop-workspace-up = emptyKeybinding;
            smart-gaps = true;
            stacking-with-mouse = true;
            tile-by-default = true;
            tile-enter = emptyKeybinding;
            tile-move-down-global = [ "<Super><Control>j" ];
            tile-move-left-global = [ "<Super><Control>h" ];
            tile-move-right-global = [ "<Super><Control>l" ];
            tile-move-up-global = [ "<Super><Control>k" ];
            tile-orientation = emptyKeybinding;
            toggle-floating = [ "<Super><Shift>v" ];
            toggle-stacking-global = [ "<Super><Shift>m" ];
            toggle-tiling = emptyKeybinding;
          };
          "org/gnome/system/location".enabled = true;
        };
        programs = {
          ghostty.settings = {
            app-notifications = "no-clipboard-copy";
            maximize = lib.mkForce false;
          };
          gnome-shell = {
            enable = true;
            extensions = [
              { package = popShellWithoutIndicator; }
            ];
          };
        };
      };
  };
}
