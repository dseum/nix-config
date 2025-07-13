{ pkgs }:
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  pkgs.docker
  pkgs.docker-compose
  pkgs.llvmPackages_20.clangWithLibcAndBasicRtAndLibcxx
  pkgs.unzip
]
