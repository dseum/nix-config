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
        pkgs,
        ...
      }:
      {
        imports = [
          ../shared/home-manager.nix
        ];
        home = {
          homeDirectory = "/home/${user}";
          packages = import ./packages.nix { inherit pkgs; };
          username = "${user}";
        };
      };
  };
}
