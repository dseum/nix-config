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
    useUserPackages = true;
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
          homeDirectory = "/home/${user}";
          packages = pkgs.callPackage ./packages.nix { };
          username = "${user}";
        };
      };
  };
}
