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
          homeDirectory = "/home/${user}";
          packages = pkgs.callPackage ./packages.nix { };
          username = "${user}";
        };
      };
  };
}
