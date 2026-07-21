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
      # https://github.com/NixOS/nixpkgs/pull/543825 — remove once merged and pulled in.
      # vscode >= 1.129.0 on Darwin ships node_modules under node_modules.asar.unpacked,
      # but generic.nix still points postPatch's ripgrep chmod at the plain node_modules
      # path, so the build fails. Rewrite the path to match the PR.
      (final: prev: {
        vscode =
          if prev.stdenv.hostPlatform.isDarwin && prev.lib.versionAtLeast prev.vscode.version "1.129.0" then
            prev.vscode.overrideAttrs (oldAttrs: {
              postPatch = builtins.replaceStrings
                [ "Contents/Resources/app/node_modules/" ]
                [ "Contents/Resources/app/node_modules.asar.unpacked/" ]
                oldAttrs.postPatch;
            })
          else
            prev.vscode;
      })
      (final: prev: {
        spotify = prev.spotify.overrideAttrs (oldAttrs: {
          src =
            if (prev.stdenv.isDarwin && prev.stdenv.isAarch64) then
              prev.fetchurl {
                url = "https://web.archive.org/web/20260613224337/http://download.scdn.co/SpotifyARM64.dmg";
                hash = "sha256-pRfQpuLLqvUOlr+742+MoLqSVwKDYxm+yk5Yrr8IrUI=";
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
