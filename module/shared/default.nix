{ pkgs, nix-vscode-extensions, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [ nix-vscode-extensions.overlays.default ];
  };
  fonts.packages = [
    pkgs.ibm-plex
    pkgs.newcomputermodern
  ];
}
