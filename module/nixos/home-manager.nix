{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  shared-files = import ../shared/files.nix { inherit config pkgs; };
in
{
  home-manager = {
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
        programs.ghostty.package = pkgs.ghostty.overrideAttrs (_: {
          preBuild = ''
            shopt -s globstar
            sed -i 's/^const xev = @import("xev");$/const xev = @import("xev").Epoll;/' **/*.zig
            shopt -u globstar
          '';
        });
        home = {
          file = shared-files // import ./files.nix { inherit config user; };
          homeDirectory = "/home/${user}";
          packages = pkgs.callPackage ./packages.nix { };
          username = "${user}";
        };
      };
  };
}
