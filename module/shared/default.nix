{
  pkgs,
  nix-vscode-extensions,
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
    overlays = [ nix-vscode-extensions.overlays.default ];
  };
  fonts.packages = [
    pkgs.ibm-plex
    pkgs.newcomputermodern
  ];
}
