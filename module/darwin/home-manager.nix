{
  nix-index-database,
  user,
  targetDir,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = {
      inherit targetDir;
    };
    sharedModules = [ nix-index-database.homeModules.nix-index ];
    useGlobalPkgs = true;
    users.${user} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          ../shared/home-manager.nix
        ];
        home.packages = import ./packages.nix { inherit pkgs; };
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than=7d";
        };
        programs.ghostty.package = null;
        programs.man.generateCaches = false;
        xdg.configFile."skhd/skhdrc" =
          let
            effect = ./config/skhd/effect;
            ghosttyNewWindow = pkgs.writeScriptBin "ghostty-new-window" ''
              #!/usr/bin/osascript
              tell application "Ghostty"
                new window
                activate
              end tell
            '';
            heliumNewWindow = pkgs.writeShellScriptBin "helium-new-window" ''
              if [[ ! -f "$HOME/Library/Application Support/net.imput.helium/$1/Preferences" ]]; then
                echo "Helium profile does not exist: $1" >&2
                exit 1
              fi

              # -n forwards arguments even when Chromium's existing browser process handles the request
              exec /usr/bin/open -n -a "/Applications/Nix Apps/Helium.app" --args \
                --profile-directory="$1" --new-window --no-first-run
            '';
          in
          {
            text = ''
              shift + lalt - r : yabai -m space --rotate 270

              shift + lalt - j : yabai -m window --swap south
              shift + lalt - k : yabai -m window --swap north
              shift + lalt - h : yabai -m window --swap west
              shift + lalt - l : yabai -m window --swap east

              lalt - j : yabai -m window --focus south
              lalt - k : yabai -m window --focus north
              lalt - h : yabai -m window --focus west
              lalt - l : yabai -m window --focus east

              shift + ctrl - p : yabai -m window --space prev && yabai -m space --focus prev
              shift + ctrl - n : yabai -m window --space next && yabai -m space --focus next

              shift + ctrl - 0x32 : yabai -m window --space 1 && yabai -m space --focus 1
              shift + ctrl - 1 : yabai -m window --space 2 && yabai -m space --focus 2
              shift + ctrl - 2 : yabai -m window --space 3 && yabai -m space --focus 3
              shift + ctrl - 3 : yabai -m window --space 4 && yabai -m space --focus 4
              shift + ctrl - 4 : yabai -m window --space 5 && yabai -m space --focus 5
              shift + ctrl - 5 : yabai -m window --space 6 && yabai -m space --focus 6
              shift + ctrl - q : yabai -m window --space 7 && yabai -m space --focus 7
              shift + ctrl - w : yabai -m window --space 8 && yabai -m space --focus 8
              shift + ctrl - e : yabai -m window --space 9 && yabai -m space --focus 9

              lalt - p : yabai -m space --focus prev
              lalt - n : yabai -m space --focus next

              lalt - 0x32 : ${effect} 1
              lalt - 1 : ${effect} 2
              lalt - 2 : ${effect} 3
              lalt - 3 : ${effect} 4
              lalt - 4 : ${effect} 5
              lalt - 5 : ${effect} 6
              lalt - q : ${effect} 7
              lalt - w : ${effect} 8
              lalt - e : ${effect} 9
              lalt - r : ${effect} 10

              shift + lalt - m : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "stack" then "bsp" elif .type == "bsp" then "float" else "stack" end')

              shift + lalt - e : ${lib.getExe ghosttyNewWindow}

              shift + lalt - 1 : ${lib.getExe heliumNewWindow} "Default"
              shift + lalt - 2 : ${lib.getExe heliumNewWindow} "Profile 1"
              shift + lalt - 3 : ${lib.getExe heliumNewWindow} "Profile 2"
              shift + lalt - 4 : ${lib.getExe heliumNewWindow} "Profile 3"

              ctrl + lcmd - z : pmset sleepnow

              ctrl + lalt - q : yabai --stop-service
              ctrl + lalt - s : yabai --start-service
              ctrl + lalt - r : yabai --restart-service
            '';
          };
        xdg.configFile."yabai" = {
          source = config.lib.file.mkOutOfStoreSymlink (targetDir + "/module/darwin/config/yabai");
          recursive = true;
        };
      };
  };
}
