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
                url = "https://web.archive.org/web/20260112184209/http://download.scdn.co/SpotifyARM64.dmg";
                hash = "sha256-jOn4hPbxIQncdjkuySTsBaFzM6VpojbMMgph/Vpah1k=";
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
