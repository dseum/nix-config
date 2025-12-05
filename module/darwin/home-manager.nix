{
  self,
  config,
  pkgs,
  lib,
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
    users.${user} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        imports = [
          ../shared/home-manager.nix
        ];
        home.packages = pkgs.callPackage ./packages.nix { inherit pkgs; };
        programs.ghostty.package = null;
        targets.darwin.linkApps.enable = false;
        xdg.configFile."skhd/skhdrc" =
          let
            effect = ./config/skhd/effect;
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

              shift + lalt - 1 : /Applications/Helium.app/Contents/MacOS/Helium --profile-directory="Profile 0" --new-window
              shift + lalt - 2 : /Applications/Helium.app/Contents/MacOS/Helium --profile-directory="Profile 1" --new-window
              shift + lalt - 3 : /Applications/Helium.app/Contents/MacOS/Helium --profile-directory="Profile 2" --new-window
              shift + lalt - 4 : /Applications/Helium.app/Contents/MacOS/Helium --profile-directory="Profile 3" --new-window
              shift + lalt - 5 : /Applications/Helium.app/Contents/MacOS/Helium --profile-directory="Profile 4" --new-window

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
