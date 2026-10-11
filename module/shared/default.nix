{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../packages/helium/module.nix
  ];

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
      trusted-users = [ user ];
      warn-dirty = false;
      show-trace = true;
      keep-outputs = true;
    };
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (_final: prev: {
        codex = prev.codex.overrideAttrs (
          finalAttrs: _oldAttrs: {
            version = "0.162.1";
            src = prev.fetchFromGitHub {
              owner = "openai";
              repo = "codex";
              tag = "rust-v${finalAttrs.version}";
              hash = "sha256-vYVQoXQdaK0bejUzcpf9uVrzNWWWAct9AsO/t261FAs=";
            };
            cargoHash = "sha256-UTu+ws1DqL375C+1jaVI9HBqDHnTuAQr7/h1rSzsEzg=";
            cargoDeps = prev.rustPlatform.fetchCargoVendor {
              inherit (finalAttrs) src sourceRoot;
              name = "codex-${finalAttrs.version}";
              hash = finalAttrs.cargoHash;
            };
          }
        );
      })
    ];
  };
  fonts.packages = [
    pkgs.ibm-plex
    pkgs.newcomputermodern
  ];
}
