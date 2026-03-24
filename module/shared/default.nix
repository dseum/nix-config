{
  pkgs,
  nix-vscode-extensions,
  user,
  ...
}:
{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings = {
      download-buffer-size = 268435456; # 256 MiB
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "@admin"
        "${user}"
      ];
      warn-dirty = false;
      show-trace = true;
      keep-outputs = true;
      keep-derivations = true;
    };
  };
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
                url = "https://web.archive.org/web/20260319173555/http://download.scdn.co/SpotifyARM64.dmg";
                hash = "sha256-uB1860OHQpOeGLNbQqmvEfttTMuU5AdHThEwAA4NEkE=";
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
