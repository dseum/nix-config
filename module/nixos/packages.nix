{ pkgs }:
let
  caffeinate = pkgs.writeShellApplication {
    name = "caffeinate";
    runtimeInputs = [ pkgs.gnome-session ];
    text = ''
      if (( $# == 0 )); then
        exec gnome-session-inhibit \
          --inhibit=idle \
          --inhibit=suspend \
          --reason=Caffeinate \
          --inhibit-only
      fi

      exec gnome-session-inhibit \
        --inhibit=idle \
        --inhibit=suspend \
        --reason=Caffeinate \
        "$@"
    '';
  };
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  caffeinate
  pkgs._1password-gui
  pkgs.docker
  pkgs.docker-compose
  pkgs.llvmPackages_20.clang-tools
  pkgs.llvmPackages_20.clangWithLibcAndBasicRtAndLibcxx
  pkgs.unzip
  pkgs.xprop
]
