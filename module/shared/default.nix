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
          finalAttrs: oldAttrs: {
            version = "0.163.0";
            buildCommit = "83086188ae0614bd882818ff1aa23f3194962012";
            src = prev.fetchFromGitHub {
              owner = "openai";
              repo = "codex";
              tag = "rust-v${finalAttrs.version}";
              hash = "sha256-Fa9dfiGJy+uqSF4A0EM6AQQhhjQdu+jfhKzqXid9PNA=";
            };
            cargoHash = "sha256-TG1fDHQCRDDbk+G0NS/9NTouJupq0Zisi4LIJY4SgYw=";
            cargoDeps = oldAttrs.cargoDeps.overrideAttrs (vendorAttrs: {
              name = "codex-${finalAttrs.version}-vendor";
              vendorStaging = vendorAttrs.vendorStaging.overrideAttrs {
                inherit (finalAttrs) src sourceRoot;
                name = "codex-${finalAttrs.version}-vendor-staging";
                outputHash = finalAttrs.cargoHash;
              };
            });
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
