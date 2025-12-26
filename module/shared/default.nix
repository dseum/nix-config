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
                url = "https://web.archive.org/web/20251218095912/http://download.scdn.co/SpotifyARM64.dmg";
                hash = "sha256-Jx7pmRn1x1qV38Ku6KE6m4gABnM6FlfYis20O+zU1Y8=";
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
