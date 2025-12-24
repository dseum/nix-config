{ pkgs, nix-vscode-extensions, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      nix-vscode-extensions.overlays.default
      (final: prev: {
        spotify = prev.spotify.overrideAttrs (oldAttrs: {
          src =
            if (prev.stdenv.isDarwin && prev.stdenv.isAarch64) then
              prev.fetchurl {
                url = "https://web.archive.org/web/20251029235406/https://download.scdn.co/SpotifyARM64.dmg";
                hash = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ=";
              }
            else
              oldAttrs.src;
        });
      })
    ];
  };
  fonts.packages = [
    pkgs.ibm-plex
    pkgs.newcomputermodern
  ];
}
