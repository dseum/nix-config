{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (final: _prev: {
      helium = final.callPackage ./. { };
    })
  ];

  environment.systemPackages = [ pkgs.helium ];
  environment.etc."1password/custom_allowed_browsers" =
    lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.programs._1password-gui.enable)
      {
        mode = "0755";
        text = lib.mkAfter "helium";
      };
}
