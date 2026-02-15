{ pkgs, nix-vscode-extensions, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "google-chrome-144.0.7559.97"
      ];
    };
    overlays = [
      nix-vscode-extensions.overlays.default
      (final: prev: {
        spotify = prev.spotify.overrideAttrs (oldAttrs: {
          src =
            if (prev.stdenv.isDarwin && prev.stdenv.isAarch64) then
              prev.fetchurl {
                url = "https://web.archive.org/web/20260213045156/http://download.scdn.co/SpotifyARM64.dmg";
                hash = "sha256-cslyAkpAXsVvIfx7tsDpDxnSjidH2uHCeFBq3pXFaMo=";
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
