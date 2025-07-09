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
  shared-files = import ../shared/files.nix { inherit config pkgs; };
in
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
        home = {
          file = shared-files // import ./files.nix { inherit config user; };
          packages = pkgs.callPackage ./packages.nix { inherit pkgs; };
        };
        programs.ghostty.package = null;
        xdg.configFile."skhd" = {
          source = config.lib.file.mkOutOfStoreSymlink ./config/skhd;
          recursive = true;
        };
        xdg.configFile."yabai" = {
          source = config.lib.file.mkOutOfStoreSymlink ./config/yabai;
          recursive = true;
        };
      };
  };
}
